use sql1;

select * from dbo.nashvillehousing
order by UniqueID;




-----------------------------------------------------------------------------------


-- standardize date format



select saledateconverted, convert(Date, SaleDate) from dbo.nashvillehousing
order by UniqueID;


update dbo.nashvillehousing
set SaleDate = convert(Date, SaleDate);


alter table nashvillehousing
add saledateconverted Date;

update nashvillehousing
set saledateconverted = convert(Date, SaleDate);



select * from dbo.nashvillehousing
order by UniqueID;







-------------------------------------------------------------------------------------







--- populate property address


select *
from dbo.nashvillehousing
order by ParcelID
--where PropertyAddress is null;


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from dbo.nashvillehousing a
join dbo.nashvillehousing b
	on a.parcelid = b.parcelid
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;


update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from dbo.nashvillehousing a
join dbo.nashvillehousing b
	on a.parcelid = b.parcelid
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;







------------------------------------------------------------------------








-- breaking out address into individual column


select PropertyAddress
from dbo.nashvillehousing;
--order by ParcelID


---splitting column using parsename and substring

select
PARSENAME(replace(PropertyAddress,',','.'),1),
PARSENAME(replace(PropertyAddress,',','.'),2)
from nashvillehousing



select 
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as address,
substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as address
from dbo.nashvillehousing;




alter table nashvillehousing
add propertysplitaddress Nvarchar(255);

update nashvillehousing
set propertysplitaddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);



alter table nashvillehousing
add propertysplitcity Nvarchar(255);

update nashvillehousing
set propertysplitcity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));


select * 
from nashvillehousing;





-- owner address


select OwnerAddress
from nashvillehousing;




select OwnerAddress
from nashvillehousing;


select
PARSENAME(replace(OwnerAddress, ',', '.'), 3),
PARSENAME(replace(OwnerAddress, ',', '.'), 2),
PARSENAME(replace(OwnerAddress, ',', '.'), 1)
from nashvillehousing



alter table nashvillehousing
add OwnerSplitAddress nvarchar(255);


update nashvillehousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'), 3);



alter table nashvillehousing
add OwnerSplitcity nvarchar(255);


update nashvillehousing
set OwnerSplitcity = PARSENAME(replace(OwnerAddress, ',', '.'), 2);


alter table nashvillehousing
add OwnerSplitstate nvarchar(255);



update nashvillehousing
set OwnerSplitstate = PARSENAME(replace(OwnerAddress, ',', '.'), 1);



select *
from nashvillehousing;












-----------------------------------------------------------------------------------------------












--- change y and n into yes or no in 'sold as vacant' field


select distinct SoldAsVacant, COUNT(SoldAsVacant) as total_count
from nashvillehousing
group by SoldAsVacant
order by 2;



select SoldAsVacant,
	case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		Else SoldAsVacant
		END 
from nashvillehousing




update nashvillehousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		Else SoldAsVacant
		END 







-------------------------------------------------------------------------------------













--- remove duplicates




with Rownumcte as(
select
*,ROW_NUMBER() over(partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference order by UniqueID) row_num
from nashvillehousing
--order by ParcelID
--where row_num > 1
)
delete 
from Rownumcte
where row_num > 1
--order by PropertyAddress



with Rownumcte as(
select
*,ROW_NUMBER() over(partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference order by UniqueID) row_num
from nashvillehousing
--order by ParcelID
--where row_num > 1
)
select *
from Rownumcte
where row_num > 1




---------------------------------------------------------------------------------



---delete unused columns



select * from
nashvillehousing;



alter table nashvillehousing
drop column OwnerAddress, TaxDistrict, PropertyAddress+

alter table nashvillehousing
drop column SaleDate