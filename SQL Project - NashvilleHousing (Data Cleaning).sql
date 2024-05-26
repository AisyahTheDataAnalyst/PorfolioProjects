/* DATA CLEANING IN SQL */ 

-- 1. Standardize Date Format
-- 2. Populate Property Address Date
-- 3. Breaking Out Address into Individual Columns (Address, City, State)
-- 4. Change Y & N to Yes & No in 'Sold As Vacant' field --> CASE STATEMENT
-- 5. Remove Duplicates --> CTE
-- 6. Delete Unused Columns ( SaleDate, PropertyAddress, OwnerAddress, TaxDistrict)




---OVERVIEW
 SELECT *
 FROM PortfolioProject.dbo.NashvilleHousing



-----------------------------------------------------
-- 1. Standardize Date Format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)
-- ITS NOT DOING IT ONTO THE DATA, SO WERE GONNA DO ALTER TABLE

ALTER TABLE  NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM NashvilleHousing


-----------------------------------------------------
--2. Populate Property Address Date
-- Handle NULLS FIRST, only then Breaking Out Address into Individual Columns to avoid deleting property address

SELECT *
FROM NashvilleHousing
WHERE PropertyAddress IS NULL 
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL 

UPDATE a
SET  PropertyAddress =  ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL 

SELECT *
FROM NashvilleHousing
WHERE PropertyAddress IS NULL 
ORDER BY ParcelID



-----------------------------------------------------
--3. Breaking Out Address into Individual Columns (Address, City, State)
--3.1 Handling PropertyAddress --> SUBSTRING

SELECT PropertyAddress 
FROM NashvilleHousing
--WHERE PropertyAddress IS NULL 
--ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) AS Address 
, SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM NashvilleHousing

ALTER TABLE  NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);
--using nvarchar 255 afraid that it might a lot of rows

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE  NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


SELECT *
FROM NashvilleHousing



--3.2 Handling OwnerAdress --> PARSENAME

SELECT OwnerAddress
FROM NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM NashvilleHousing


ALTER TABLE  NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)


ALTER TABLE  NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)


ALTER TABLE  NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

SELECT *
FROM NashvilleHousing




-------------------------------------------------------
--4. Change Y & N to Yes & No in 'Sold As Vacant' field --> CASE STATEMENT
-- Choosing Yes & No (Vastly More POpulated One)

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
       END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
     END

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2




---------------------------------------------------------
--5. Remove Duplicates --> CTE

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER () OVER (
	PARTITION BY ParcelID,
              PropertyAddress,
			  SalePrice,
			  SaleDate,
			  LegalReference
			  ORDER BY 
				UniqueID
				) row_num
FROM NashvilleHousing
--WHERE row_num > 1 (Cant do this in windows function, need to do in CTE)
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER () OVER (
	PARTITION BY ParcelID,
              PropertyAddress,
			  SalePrice,
			  SaleDate,
			  LegalReference
			  ORDER BY 
				UniqueID
				) row_num
FROM NashvilleHousing
--WHERE row_num > 1 (Cant do this in windows function, need to do in CTE)
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER () OVER (
	PARTITION BY ParcelID,
              PropertyAddress,
			  SalePrice,
			  SaleDate,
			  LegalReference
			  ORDER BY 
				UniqueID
				) row_num
FROM NashvilleHousing
--WHERE row_num > 1 (Cant do this in windows function, need to do in CTE)
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


----------------------------------------------------------
--6. Delete Unused Columns ( SaleDate, PropertyAddress, OwnerAddress, TaxDistrict)


SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN  SaleDate, PropertyAddress, OwnerAddress, TaxDistrict
--They are not used or are already converted/split up

SELECT *
FROM NashvilleHousing



-- Remember, the whole point of data cleaning is to clean the data to make it more usable 















































































