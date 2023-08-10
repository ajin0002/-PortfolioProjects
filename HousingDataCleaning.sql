-- Data Cleaning with SQL

select * from portflioproject.nashvillehousingdata;

------------------------------------------------------------------------
-- Standardize Date Format 

select SaleDate from portflioproject.nashvillehousingdata;
set Sql_safe_updates = 0;
update portflioproject.nashvillehousingdata  set SaleDate =  STR_TO_DATE(SaleDate, '%M %e, %Y');
alter table portflioproject.nashvillehousingdata modify column Saledate date;


---------------------------------------------------------------------------------------------

-- Populate property address data (it got null values, so we will get that will parcelID as it same for each address)


select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, coalesce(a.PropertyAddress,b.PropertyAddress) from portflioproject.nashvillehousingdata as a 
join portflioproject.nashvillehousingdata as b
on a.ParcelID = b.ParcelID and a.uniqueid <> b.uniqueid
where a.PropertyAddress is null; 


UPDATE portflioproject.nashvillehousingdata AS a
JOIN portflioproject.nashvillehousingdata AS b
ON a.ParcelID = b.ParcelID AND a.uniqueid <> b.uniqueid
SET a.PropertyAddress = COALESCE(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;

--------------------------------------------------------------------------------------

-- Breaking out address into Individual Columns (Address, City, State)

select PropertyAddress from portflioproject.nashvillehousingdata;

select substring(propertyaddress,1,Locate(",",propertyaddress)-1),  
substring(propertyaddress,Locate(",",propertyaddress)+1,length(propertyaddress))
from portflioproject.nashvillehousingdata;

alter table portflioproject.nashvillehousingdata add PropertySplitAdderss varchar(255);
update portflioproject.nashvillehousingdata 
set PropertySplitAdderss = substring(propertyaddress,1,Locate(",",propertyaddress)-1);

alter table portflioproject.nashvillehousingdata add PropertySplitCity varchar(255);
update portflioproject.nashvillehousingdata 
set PropertySplitCity = substring(propertyaddress,Locate(",",propertyaddress)+1,length(propertyaddress));

-- Spliting Owner Address
select substring_index(OwnerAddress,",",1),substring_index(substring_index(OwnerAddress,",",2),",",-1),substring_index(OwnerAddress,",",-1)
 from portflioproject.nashvillehousingdata;

alter table portflioproject.nashvillehousingdata add OwnerSplitAdderss varchar(255);
update portflioproject.nashvillehousingdata 
set OwnerSplitAdderss = substring_index(OwnerAddress,",",1);

alter table portflioproject.nashvillehousingdata add OwnerSplitcity varchar(255);
update portflioproject.nashvillehousingdata 
set OwnerSplitcity = substring_index(substring_index(OwnerAddress,",",2),",",-1);

alter table portflioproject.nashvillehousingdata add OwnerSplitState varchar(255);
update portflioproject.nashvillehousingdata 
set OwnerSplitState = substring_index(OwnerAddress,",",-1);

-----------------------------------------------------------------------------------------
-- Changing Y and N to Yes and No in "Sold as Vacent" field

select distinct SoldAsVacant from portflioproject.nashvillehousingdata;

update portflioproject.nashvillehousingdata set SoldasVacant = 
case
when SoldasVacant = "Y" then "Yes" 
when SoldasVacant = "N" then "No"
else SoldasVacant
end;

-----------------------------------------------------------------------------------------

-- Remove Duplicates

 Delete from portflioproject.nashvillehousingdata where uniqueid in 
 (select uniqueid from (select *, row_number() over(partition by ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference order by uniqueid) as row_num 
from portflioproject.nashvillehousingdata) as a where row_num>1);


----------------------------------------------------------------------------------------------
-- Delete unused columns
select * from portflioproject.nashvillehousingdata;

ALTER TABLE portflioproject.nashvillehousingdata
DROP column owneraddress, DROP column propertyaddress, DROP column Taxdistrict;

