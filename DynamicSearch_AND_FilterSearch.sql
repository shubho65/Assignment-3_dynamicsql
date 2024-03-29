USE [learning]
GO
/****** Object:  StoredProcedure [dbo].[DynamicSearch2a]    Script Date: 9/13/2019 12:32:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[DynamicSearch2a] 
	-- Add the parameters for the stored procedure here
	@PageNbr            INT = 1,
    @PageSize           INT = 10,
	@sortcol			NVARCHAR(50),
    -- Optional Filters for Dynamic Search
    @Name				NVARCHAR(250) = NULL, 
    @Price				DECIMAL(18,2) = NULL,
	@Description		nvarchar(MAX)=NULL,
	@ImageUrl			nvarchar(250)=NULL,
	@Category           nvarchar(50) = NULL, 
	@Rating				decimal(18, 2)=NULL,
	@Weight				decimal(18, 2)=NULL,
	@IsActive			bit=NULL,
	@Width				int=NULL,
	@Height				int=NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare
		@FirstRec INT,
		@LastRec INT,
		@TotalRows INT,
		@sql	   nvarchar(MAX),
		@paramlist  nvarchar(4000),
		@nl         char(2) = char(13) + char(10) 

	SET @FirstRec  = ( @PageNbr - 1 ) * @PageSize
    SET @LastRec   = ( @PageNbr * @PageSize + 1 ) 
    SET @TotalRows = @LastRec - @FirstRec + 1;




SET @sql='WITH CTE_Results
    AS (
        SELECT ROW_NUMBER() OVER (ORDER BY id) AS ROWNUM,
            [Name], 
            Price,
			[Description],
			ImageUrl,
			Category,
			Rating,
			Weight,
			IsActive,
			Widht,
			Height 
        FROM dbo.Product
        WHERE 1 = 1' 

   IF @Name IS NOT NULL                                            
   SET @sql += ' AND [Name] = @Name'                   
   IF @Price IS NOT NULL                                            
   SET @sql += ' AND Price = @Price'   
   IF @Description IS NOT NULL                                            
   SET @sql += ' AND Description = @Description'     
   IF @ImageUrl IS NOT NULL                                            
   SET @sql += ' AND ImageUrl = @ImageUrl'     
   IF @Category IS NOT NULL                                            
   SET @sql += ' AND @ategory = @Category'     
   IF @Rating IS NOT NULL                                            
   SET @sql += ' AND Rating = @Rating'     
   IF @Weight IS NOT NULL                                            
   SET @sql += ' AND Weight = @Weight'      
   IF @IsActive IS NOT NULL                                            
   SET @sql += ' AND IsActive = @IsActive'  
   IF @Width IS NOT NULL                                            
   SET @sql += ' AND Width = @Width'  
   IF @Weight IS NOT NULL                                            
   SET @sql += ' AND Height = @Height'                
   SET @sql += ' )' + @nl
   SET @sql += 'SELECT
			[Name], 
            Price,
			[Description],
			ImageUrl,
			Category,
			Rating 
        FROM CTE_Results AS CPC
    WHERE
        ROWNUM > @FirstRec 
    AND ROWNUM < @LastRec
    Order by CASE @sortcol WHEN ''Name''			 THEN [Name]
                       WHEN		''Description''      THEN Description
					   WHEN		''Category''         THEN Category
         END, 
			 CASE @sortcol WHEN ''Price''       THEN Price		
			 CASE @sortcol WHEN ''Rating''      THEN Rating	
			 CASE @sortcol WHEN ''Weight''      THEN Weight		 
			 CASE @sortcol WHEN ''Width''       THEN Width	
			 CASE @sortcol WHEN ''Height''      THEN Height		 
			 END 
		 ASC' ;

PRINT @sql  

SELECT @paramlist =    '@Name				NVARCHAR(250), 
						@Price				DECIMAL(18,2),
						@Description		nvarchar(MAX),
						@ImageUrl			NVARCHAR(250),
						@Category           NVARCHAR(50), 
						@Rating				decimal(18,2),
						@Weight				decimal(18,2),
						@IsActive			bit,
						@Width				int,
						@Height				int,
						@FirstRec			int,
						@LastRec			int,
						@sortcol			NVARCHAR(50)'

EXEC sp_executesql @sql, @paramlist,                               
                   @Name,@Price,@Description,
				   @ImageUrl,@Category,@Rating,@Weight,@IsActive,@Width,@Height,
				   @FirstRec=@FirstRec,@LastRec=@LastRec,@sortcol=@sortcol

END

