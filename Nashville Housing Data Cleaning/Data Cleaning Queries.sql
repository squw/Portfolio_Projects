/*
	Cleaning Data in SQL Queries

*/


SELECT *
FROM [Data Cleaning Project]..[Nashville_Housing]


---------------------------------------------------------------------------------------------------------------

-- #1 Standardize Data Format

SELECT *
FROM [Data Cleaning Project]..[Nashville_Housing]

-- rename the original "SaleDate" to "SaleDate_old" in Object Explorer

ALTER TABLE Nashville_Housing
ADD SaleDate Date

UPDATE Nashville_Housing
SET SaleDate = CONVERT(Date, SaleDate_old)

ALTER TABLE Nashville_Housing
DROP COLUMN SaleDate_old


---------------------------------------------------------------------------------------------------------------

-- #2 Populate PropertyAddress Data


SELECT *
FROM [Data Cleaning Project]..[Nashville_Housing]
-- WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Data Cleaning Project]..[Nashville_Housing] AS a
JOIN [Data Cleaning Project]..[Nashville_Housing] AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL



UPDATE a
SET a.PropertyAddress = b.PropertyAddress
FROM [Data Cleaning Project]..[Nashville_Housing] AS a
JOIN [Data Cleaning Project]..[Nashville_Housing] AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


---------------------------------------------------------------------------------------------------------------

-- #3 Breaking Out Address into Individual Columns (Address, City, State)


SELECT PropertyAddress, PropertyCity
FROM [Data Cleaning Project]..[Nashville_Housing]


SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address, 
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM [Data Cleaning Project]..[Nashville_Housing]

-- rename the old 'PropertyAddress' into 'PropertyAddress_old'

ALTER TABLE Nashville_Housing
ADD PropertyAddress NVARCHAR(255)

UPDATE Nashville_Housing
SET PropertyAddress = SUBSTRING(PropertyAddress_old, 1, CHARINDEX(',', PropertyAddress_old)-1)



ALTER TABLE Nashville_Housing
ADD PropertyCity NVARCHAR(255)

UPDATE Nashville_Housing
SET PropertyCity = SUBSTRING(PropertyAddress_old, CHARINDEX(',', PropertyAddress_old)+1, LEN(PropertyAddress_old))





SELECT *
FROM [Data Cleaning Project]..[Nashville_Housing]

-- rename 'OwnerAddress' as 'OwnerAddress_old'

SELECT OwnerAddress_old
FROM [Data Cleaning Project]..[Nashville_Housing]

SELECT 
	PARSENAME(REPLACE(OwnerAddress_old, ',', '.'), 3) AS OwnerAddress,
	PARSENAME(REPLACE(OwnerAddress_old, ',', '.'), 2) AS OwnerCity,
	PARSENAME(REPLACE(OwnerAddress_old, ',', '.'), 1) AS OwnerState
FROM [Data Cleaning Project]..[Nashville_Housing]


ALTER TABLE [Data Cleaning Project]..[Nashville_Housing]
ADD OwnerAddress NVARCHAR(255)

ALTER TABLE [Data Cleaning Project]..[Nashville_Housing]
ADD OwnerCity NVARCHAR(255)

ALTER TABLE [Data Cleaning Project]..[Nashville_Housing]
ADD OwnerState NVARCHAR(255)


UPDATE [Data Cleaning Project]..[Nashville_Housing]
SET OwnerAddress = PARSENAME(REPLACE(OwnerAddress_old, ',', '.'), 3)

UPDATE [Data Cleaning Project]..[Nashville_Housing]
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress_old, ',', '.'), 2)

UPDATE [Data Cleaning Project]..[Nashville_Housing]
SET OwnerState = PARSENAME(REPLACE(OwnerAddress_old, ',', '.'), 1)




---------------------------------------------------------------------------------------------------------------

-- #4 Change Y and N into Yes and No in "Sold as Vacant" Field

-- rename 'SoldAsVacant' as 'SoldAsVacant_old'

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) AS num
FROM [Data Cleaning Project]..[Nashville_Housing]
GROUP BY SoldAsVacant
ORDER BY num


SELECT 
	SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END AS SoldAsVacant_corrected
FROM [Data Cleaning Project]..[Nashville_Housing]

UPDATE [Data Cleaning Project]..[Nashville_Housing]
SET SoldAsVacant = (CASE
						WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
					END)



---------------------------------------------------------------------------------------------------------------

-- #5 Remove Duplicates

WITH RowNum_CTE AS(
	SELECT 
		*,
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					 SalePrice,
					 LegalReference,
					 SaleDate,
					 PropertyAddress,
					 PropertyCity
		ORDER BY UniqueID) AS row_num
	FROM [Data Cleaning Project]..[Nashville_Housing])
DELETE
FROM RowNum_CTE
WHERE row_num > 1



---------------------------------------------------------------------------------------------------------------

-- #6 Delete Unused Columns

SELECT *
FROM [Data Cleaning Project]..[Nashville_Housing]

ALTER TABLE [Data Cleaning Project]..[Nashville_Housing]
DROP COLUMN PropertyAddress_old

ALTER TABLE [Data Cleaning Project]..[Nashville_Housing]
DROP COLUMN OwnerAddress_old

ALTER TABLE [Data Cleaning Project]..[Nashville_Housing]
DROP COLUMN SaleDate, TaxDistrict






---------------------------------------------------------------------------------------------------------------