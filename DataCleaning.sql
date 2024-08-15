SELECT * FROM NashvilleHousing;

------------------------------------------------------------------------------------------------------

-- standardize sales date

SELECT SaleDate FROM NashvilleHousing;

SELECT saledateconverted,CONVERT(Date,SaleDate) FROM NashvilleHousing;

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate);

ALTER TABLE NashvilleHousing
ADD saledateconverted DATE;

UPDATE NashvilleHousing
SET saledateconverted = CONVERT(Date,SaleDate);


-------------------------------------------------------------------------------------------------------------

-- POPULATE PROPERTY ADDRESS DATA

SELECT PropertyAddress FROM NashvilleHousing;

SELECT PropertyAddress FROM NashvilleHousing
WHERE PropertyAddress is NULL;

SELECT * FROM NashvilleHousing
WHERE PropertyAddress is NULL;

SELECT a.ParcelID,b.ParcelID,a.PropertyAddress,b.PropertyAddress FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From  NashvilleHousing a
JOIN NashvilleHousing b
on a. ParcelID = b.ParcelID
AND a. UniqueID <> b. UniqueID
Where a.PropertyAddress IS NULL;

--------------------------------------------------------------------------------------------------------------

  -- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress From  NashvilleHousing;

SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',propertyAddress) -1 ) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',propertyAddress) +1, LEN(PropertyAddress)) AS Address
From  NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1 ) ;

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress));

SELECT * FROM NashvilleHousing;

         -- (SUBSTRING) ANOTHER METHOD (PARSENAME)

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',' ,'.'),3) AS OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',' ,'.'),2) AS OwnerCity,
PARSENAME(REPLACE(OwnerAddress, ',' ,'.'),1) AS OwnerState
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' ,'.'),3);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' ,'.'),2);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' ,'.'),1);

SELECT * FROM NashvilleHousing;

---------------------------------------------------------------------------------------------------------

   -- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant) FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
   CASE 
      WHEN SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
   END
FROM NashvilleHousing;

UPDATE NashvilleHousing
SET SoldAsVacant=
   CASE 
      WHEN SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
   END

-----------------------------------------------------------------------------------------------------------------

   -- REMOVE DUPLICATES
WITH ROWNUMCTE AS(
SELECT *,ROW_NUMBER() OVER(
            PARTITION BY ParcelId,
			             PropertyAddress,
						 SaleDate,
						 SalePrice,
						 LegalReference
						 ORDER BY UniqueID
			) AS row_num
FROM NashvilleHousing
--ORDER BY ParcelID;
)
--DELETE FROM ROWNUMCTE
SELECT * FROM ROWNUMCTE
WHERE row_num >1;
--ORDER BY PropertyAddress;

------------------------------------------------------------------------------------------------------
      -- DELETE UNUSED COLUMNS

SELECT * FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress,OwnerAddress,TaxDistrict;

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate;
