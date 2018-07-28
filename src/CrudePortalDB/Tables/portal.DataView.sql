﻿CREATE TABLE [portal].[DataView] (
    [ViewID]                INT             IDENTITY (1, 1) NOT NULL,
    [Title]                 NVARCHAR (100)  NOT NULL,
    [MainTable]             NVARCHAR (300)  NULL,
    [Primarykey]            NVARCHAR (300)  NULL,
    [ModificationProcedure] NVARCHAR (300)  NULL,
    [ViewProcedure]         NVARCHAR (300)  NULL,
    [DeleteProcedure]       NVARCHAR (300)  NULL,
    [ViewDescription]       NVARCHAR (4000) NULL,
    [OrderBy]               NVARCHAR (300)  NULL,
    [Flags]                 INT             CONSTRAINT [DF_DataView_Flags] DEFAULT ((63)) NOT NULL,
    [DataTableModifierButtonStyle] SMALLINT NOT NULL DEFAULT 1, 
    [DataTableFlags] INT NOT NULL DEFAULT 61, 
    [DataTableDefaultPageSize] INT NOT NULL DEFAULT 25, 
    CONSTRAINT [PK_DataView] PRIMARY KEY CLUSTERED ([ViewID] ASC)
);

