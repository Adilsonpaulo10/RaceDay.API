IF DB_ID(N'RaceDay') IS NULL
BEGIN
    CREATE DATABASE RaceDay;
END
GO
USE RaceDay;
GO
DROP TABLE IF EXISTS dbo.Result;
DROP TABLE IF EXISTS dbo.Enrolment;
DROP TABLE IF EXISTS dbo.Route;
DROP TABLE IF EXISTS dbo.Category;
DROP TABLE IF EXISTS dbo.Event;
DROP TABLE IF EXISTS dbo.[User];
GO
CREATE TABLE dbo.[User](
 UserID INT IDENTITY(1,1) NOT NULL,
 FirstName NVARCHAR(50) NOT NULL,
 LastName NVARCHAR(50) NOT NULL,
 Email NVARCHAR(255) NOT NULL,
 PasswordHash VARCHAR(64) NOT NULL,
 Role VARCHAR(20) NOT NULL,
 CONSTRAINT PK_User PRIMARY KEY(UserID),
 CONSTRAINT UQ_User_Email UNIQUE(Email),
 CONSTRAINT CK_User_Role CHECK(Role IN('Participant','Organiser'))
);
GO
CREATE TABLE dbo.Event(
 EventID INT IDENTITY(1,1) NOT NULL,
 OrganiserID INT NOT NULL,
 EventName NVARCHAR(150) NOT NULL,
 [Description] NVARCHAR(1000) NULL,
 EventDate DATETIME2(0) NOT NULL,
 [Location] NVARCHAR(200) NOT NULL,
 [Status] VARCHAR(20) NOT NULL,
 CONSTRAINT PK_Event PRIMARY KEY(EventID),
 CONSTRAINT FK_Event_Organiser FOREIGN KEY(OrganiserID) REFERENCES dbo.[User](UserID),
 CONSTRAINT CK_Event_Status CHECK([Status] IN('Upcoming','Active','Completed','Cancelled'))
);
GO
CREATE TABLE dbo.Category(
 CategoryID INT IDENTITY(1,1) NOT NULL,
 EventID INT NOT NULL,
 CategoryName NVARCHAR(100) NOT NULL,
 Distance DECIMAL(6,2) NOT NULL,
 EntryFee DECIMAL(10,2) NOT NULL,
 CONSTRAINT PK_Category PRIMARY KEY(CategoryID),
 CONSTRAINT FK_Category_Event FOREIGN KEY(EventID) REFERENCES dbo.Event(EventID),
 CONSTRAINT CK_Category_Distance CHECK(Distance > 0),
 CONSTRAINT CK_Category_EntryFee CHECK(EntryFee >= 0),
 CONSTRAINT UQ_Category_Event_Name UNIQUE(EventID,CategoryName)
);
GO
CREATE TABLE dbo.Enrolment(
 EnrolmentID INT IDENTITY(1,1) NOT NULL,
 UserID INT NOT NULL,
 CategoryID INT NOT NULL,
 EnrolmentDate DATETIME2(0) NOT NULL CONSTRAINT DF_Enrolment_Date DEFAULT(SYSDATETIME()),
 [Status] VARCHAR(20) NOT NULL,
 CONSTRAINT PK_Enrolment PRIMARY KEY(EnrolmentID),
 CONSTRAINT FK_Enrolment_User FOREIGN KEY(UserID) REFERENCES dbo.[User](UserID),
 CONSTRAINT FK_Enrolment_Category FOREIGN KEY(CategoryID) REFERENCES dbo.Category(CategoryID),
 CONSTRAINT CK_Enrolment_Status CHECK([Status] IN('Registered','Withdrawn','Completed')),
 CONSTRAINT UQ_Enrolment_User_Category UNIQUE(UserID,CategoryID)
);
GO
CREATE TABLE dbo.Result(
 ResultID INT IDENTITY(1,1) NOT NULL,
 EnrolmentID INT NOT NULL,
 FinishTime TIME(0) NULL,
 [Position] INT NULL,
 ResultStatus VARCHAR(20) NOT NULL,
 Notes NVARCHAR(500) NULL,
 CONSTRAINT PK_Result PRIMARY KEY(ResultID),
 CONSTRAINT FK_Result_Enrolment FOREIGN KEY(EnrolmentID) REFERENCES dbo.Enrolment(EnrolmentID),
 CONSTRAINT UQ_Result_Enrolment UNIQUE(EnrolmentID),
 CONSTRAINT CK_Result_Position CHECK([Position] IS NULL OR [Position] > 0),
 CONSTRAINT CK_Result_Status CHECK(ResultStatus IN('Finished','DNF','DNS'))
);
GO
CREATE TABLE dbo.Route(
 RouteID INT IDENTITY(1,1) NOT NULL,
 EventID INT NOT NULL,
 RouteName NVARCHAR(150) NOT NULL,
 Distance DECIMAL(6,2) NOT NULL,
 [Description] NVARCHAR(1000) NULL,
 CONSTRAINT PK_Route PRIMARY KEY(RouteID),
 CONSTRAINT FK_Route_Event FOREIGN KEY(EventID) REFERENCES dbo.Event(EventID),
 CONSTRAINT UQ_Route_Event UNIQUE(EventID),
 CONSTRAINT CK_Route_Distance CHECK(Distance > 0)
);
GO
INSERT INTO dbo.[User](FirstName,LastName,Email,PasswordHash,Role) VALUES
('Thabo','Mokoena','thabo.organiser@raceday.co.za',CONVERT(VARCHAR(64),HASHBYTES('SHA2_256','RaceDay123!'),2),'Organiser'),
('Lerato','Naidoo','lerato.organiser@raceday.co.za',CONVERT(VARCHAR(64),HASHBYTES('SHA2_256','RaceDay123!'),2),'Organiser'),
('Sipho','Dlamini','sipho.participant@example.com',CONVERT(VARCHAR(64),HASHBYTES('SHA2_256','RaceDay123!'),2),'Participant'),
('Amara','Pillay','amara.participant@example.com',CONVERT(VARCHAR(64),HASHBYTES('SHA2_256','RaceDay123!'),2),'Participant');
GO
INSERT INTO dbo.Event(OrganiserID,EventName,[Description],EventDate,[Location],[Status]) VALUES
((SELECT UserID FROM dbo.[User] WHERE Email='thabo.organiser@raceday.co.za'),'Cape Town Marathon','Road running event in Cape Town.','2026-10-18 06:00:00','Cape Town, Western Cape','Upcoming'),
((SELECT UserID FROM dbo.[User] WHERE Email='lerato.organiser@raceday.co.za'),'Cape Town Cycle Challenge','Cycling event for participants of different distances.','2026-11-08 06:00:00','Cape Town, Western Cape','Upcoming');
GO
INSERT INTO dbo.Category(EventID,CategoryName,Distance,EntryFee) VALUES
((SELECT EventID FROM dbo.Event WHERE EventName='Cape Town Marathon'),'10 km Run',10.00,150.00),
((SELECT EventID FROM dbo.Event WHERE EventName='Cape Town Marathon'),'21.1 km Half Marathon',21.10,300.00),
((SELECT EventID FROM dbo.Event WHERE EventName='Cape Town Marathon'),'42.2 km Marathon',42.20,450.00),
((SELECT EventID FROM dbo.Event WHERE EventName='Cape Town Cycle Challenge'),'20 km Cycle',20.00,200.00),
((SELECT EventID FROM dbo.Event WHERE EventName='Cape Town Cycle Challenge'),'40 km Cycle',40.00,300.00),
((SELECT EventID FROM dbo.Event WHERE EventName='Cape Town Cycle Challenge'),'80 km Cycle',80.00,450.00);
GO
INSERT INTO dbo.Route(EventID,RouteName,Distance,[Description]) VALUES
((SELECT EventID FROM dbo.Event WHERE EventName='Cape Town Marathon'),'Cape Town City Run Route',42.20,'Road route through central Cape Town and surrounding areas.'),
((SELECT EventID FROM dbo.Event WHERE EventName='Cape Town Cycle Challenge'),'Cape Peninsula Cycle Route',80.00,'Cycling route around the Cape Peninsula.');
GO
INSERT INTO dbo.Enrolment(UserID,CategoryID,[Status]) VALUES
((SELECT UserID FROM dbo.[User] WHERE Email='sipho.participant@example.com'),(SELECT CategoryID FROM dbo.Category WHERE CategoryName='10 km Run'),'Registered'),
((SELECT UserID FROM dbo.[User] WHERE Email='amara.participant@example.com'),(SELECT CategoryID FROM dbo.Category WHERE CategoryName='21.1 km Half Marathon'),'Registered'),
((SELECT UserID FROM dbo.[User] WHERE Email='sipho.participant@example.com'),(SELECT CategoryID FROM dbo.Category WHERE CategoryName='20 km Cycle'),'Registered'),
((SELECT UserID FROM dbo.[User] WHERE Email='amara.participant@example.com'),(SELECT CategoryID FROM dbo.Category WHERE CategoryName='40 km Cycle'),'Registered');
GO
INSERT INTO dbo.Result(EnrolmentID,FinishTime,[Position],ResultStatus,Notes) VALUES
((SELECT en.EnrolmentID FROM dbo.Enrolment en JOIN dbo.[User] u ON u.UserID=en.UserID JOIN dbo.Category c ON c.CategoryID=en.CategoryID WHERE u.Email='sipho.participant@example.com' AND c.CategoryName='10 km Run'),'00:52:34',14,'Finished','Sample completed result.'),
((SELECT en.EnrolmentID FROM dbo.Enrolment en JOIN dbo.[User] u ON u.UserID=en.UserID JOIN dbo.Category c ON c.CategoryID=en.CategoryID WHERE u.Email='amara.participant@example.com' AND c.CategoryName='21.1 km Half Marathon'),'01:58:21',37,'Finished','Sample completed result.');
GO
SELECT * FROM dbo.[User];
SELECT * FROM dbo.Event;
SELECT * FROM dbo.Category;
SELECT * FROM dbo.Route;
SELECT * FROM dbo.Enrolment;
SELECT * FROM dbo.Result;
SELECT e.EventName,COUNT(c.CategoryID) AS CategoryCount FROM dbo.Event e LEFT JOIN dbo.Category c ON e.EventID=c.EventID GROUP BY e.EventID,e.EventName;
GO