package com.qjz.declarePlatfrom.dao;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.qjz.declarePlatfrom.domain.ItemType;

public interface ItemTypeDao {
	
	public List<ItemType> listItemType(@Param("itemType_name")String itemType_name, @Param("start")int start, @Param("pageSize")int pageSize);

	public Long count(String itemType_name);
	
	public int updateItemType(ItemType itemType);

	public int addItemType(ItemType itemType);

	public int deleteItemType(Integer itemType_id);

}
