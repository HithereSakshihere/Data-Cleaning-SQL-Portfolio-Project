/*
   Cleaning Data in SQL Queries
*/
Select * 
from NashVilleHousing

----------------------Standarize Date Format

---Visualizer
select SaleDate, Convert(Date, SaleDate) 
from NashVilleHousing

---Changing DataType( in actual Table )
Alter table NashVilleHousing
Add SaleDateConverted Date

Update NashVilleHousing
SET SaleDateConverted= Convert(Date, SaleDate)

-----------------------Populate Property Address Data
----Visualizer for NULL PropertyAddress
select PropertyAddress
from NashVilleHousing
where PropertyAddress is null

--------Visualizer for Filling NULL PropertyAddress

Select NH1.ParcelID, NH1.PropertyAddress, NH2.ParcelID, NH2.PropertyAddress, isnull(NH1.PropertyAddress,NH2.PropertyAddress)
from NashVilleHousing as NH1
Join NashVilleHousing as NH2
    on NH1.ParcelID=NH2.ParcelID
	and NH1.UniqueID<>NH2.UniqueID
where NH1.PropertyAddress is null 

-------Updating the NULL valued PropertyAddressColumn

update NH1
set PropertyAddress=isnull(NH1.PropertyAddress,NH2.PropertyAddress)
from NashVilleHousing as NH1
join NashVilleHousing as NH2
     on NH1.UniqueID<>NH2.UniqueID
	 and NH1.ParcelID=NH2.ParcelID
where NH1.PropertyAddress is null

-----------------------------Breaking Out Address into individual Columns(Address, City, State)

select PropertyAddress
from NashVilleHousing

---Visualizer for breaking out Address

select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as NewAddress
from NashVilleHousing

--------------Altering table for breaking the Address

Alter table NashVilleHousing
Add PropertySplitAddress Nvarchar(255)

update NashVilleHousing
set PropertySplitAddress = Substring(PropertyAddress,1,charindex(',',PropertyAddress)-1)

Alter table NashVilleHousing
Add PropertyCity Nvarchar(255)

Update NashVilleHousing
set PropertyCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress))

-------Breaking Out Owner's Address using Other method

select  OwnerAddress
from NashVilleHousing
where OwnerAddress is not null

---Visualizer for Address Change

Select 
ParseName(replace(OwnerAddress,',','.'),3),
parseName(replace(OwnerAddress,',','.'),2),
ParseName(replace(OwnerAddress,',','.'),1)
from NashVilleHousing
where OwnerAddress is not null

---Updating the Owner's Address 

Alter Table NashVilleHousing
add OwnerSplitAddress Nvarchar(255)

update NashVilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

Alter Table NashVilleHousing
add OwnerCity Nvarchar(255)

update NashVilleHousing
set OwnerCity = PARSENAME(replace(OwnerAddress,',','.'),2)

alter table NashVilleHousing
add OwnerState Nvarchar(255)

update NashVilleHousing
Set OwnerState = ParseName(replace(OwnerAddress,',','.'),1)

----------------------------Changing Y and N to 'Yes' and 'No'
---Visualizer
Select SoldAsVacant
, Case when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
       End
from NashVilleHousing

---Updating

update NashVilleHousing
set SoldAsVacant = Case When SoldAsVacant = 'Y' then 'Yes'
                        when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant
						End

---Checking

select distinct(SoldAsVacant), count(SoldAsVacant)
from NashVilleHousing
group by SoldAsVacant
order by 2

---------------------Remove Duplicates

with RowNumCTE as(
select *,
       row_number() over(
	   Partition by ParcelID,
	                PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					Order by 
					     UniqueID
							) as row_num
from NashVilleHousing
)
Select * -------------Deleted using DELETE that's why result is an empty table
from RowNumCTE
where row_num>1
order by SalePrice

--------------------------------Deleting Unused Columns

alter table NashVilleHousing
Drop column PropertyAddress, OwnerAddress, SaleDate




