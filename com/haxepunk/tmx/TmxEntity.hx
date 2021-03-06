package com.haxepunk.tmx;

import com.haxepunk.Entity;
import com.haxepunk.Graphic;
import com.haxepunk.graphics.Graphiclist;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Tilemap;
import com.haxepunk.masks.Grid;
import com.haxepunk.masks.Masklist;

class TmxEntity extends Entity
{

	public var map:TmxMap;
	public var debugObjectMask:Bool;

	public function new(mapData:Dynamic)
	{
		super();

		if (Std.is(mapData, String))
		{
			map = new TmxMap(Xml.parse(openfl.Assets.getText(mapData)));
		}
		else if (Std.is(mapData, TmxMap))
		{
			map = mapData;
		}
		else
		{
			map = new TmxMap(mapData);
		}
#if debug
		debugObjectMask = true;
#end
	}

	public function loadGraphic(tileset:Dynamic, layerNames:Array<String>, skip:Array<Int> = null)
	{
		var gid:Int, layer:TmxLayer;
		for (name in layerNames)
		{
			if (map.layers.exists(name) == false)
			{
#if debug
				trace("Layer '" + name + "' doesn't exist");
#end
				continue;
			}
			layer = map.layers.get(name);
			var spacing = map.getTileMapSpacing(name);

#if flash
			var _tileset = openfl.Assets.getBitmapData(tileset);
#else
			var _tileset = new com.haxepunk.graphics.atlas.TileAtlas(tileset, map.tileWidth, map.tileHeight, spacing, spacing);
#end
			var tilemap = new Tilemap(_tileset, map.fullWidth, map.fullHeight, map.tileWidth, map.tileHeight, spacing, spacing);

			// Loop through tile layer ids
			for (row in 0...layer.height)
			{
				for (col in 0...layer.width)
				{
					gid = layer.tileGIDs[row][col] - 1;
					if (gid < 0) continue;
					if (skip == null || Lambda.has(skip, gid) == false)
					{
						tilemap.setTile(col, row, gid);
					}
				}
			}
			addGraphic(tilemap);
		}
	}

	public function loadMask(collideLayer:String = "collide", typeName:String = "solid", skip:Array<Int> = null)
	{
		if (!map.layers.exists(collideLayer))
		{
#if debug
				trace("Layer '" + collideLayer + "' doesn't exist");
#end
			return;
		}

		var gid:Int;
		var layer:TmxLayer = map.layers.get(collideLayer);
		var grid = new Grid(map.fullWidth, map.fullHeight, map.tileWidth, map.tileHeight);

		// Loop through tile layer ids
		for (row in 0...layer.height)
		{
			for (col in 0...layer.width)
			{
				gid = layer.tileGIDs[row][col] - 1;
				if (gid < 0) continue;
				if (skip == null || Lambda.has(skip, gid) == false)
				{
					grid.setTile(col, row, true);
				}
			}
		}

		this.mask = grid;
		this.type = typeName;
		setHitbox(grid.width, grid.height);
	}

	/*
		debugging shapes of object mask is only availble in -flash
		currently only supports ellipse object (circles only), and rectangle objects
			no polygons yet
	*/
	public function loadObjectMask(collideLayer:String = "objects", typeName:String = "solidObject")
	{	
		if (map.getObjectGroup(collideLayer) == null)
		{
#if debug
				trace("ObjectGroup '" + collideLayer + "' doesn't exist");
#end
			return;
		}

		var objectGroup:TmxObjectGroup = map.getObjectGroup(collideLayer);
		
		var masks_ar = new Array<Dynamic>();
#if debug
		var debug_graphics_ar = new Array<Dynamic>();
#end

		// Loop through objects
		for(object in objectGroup.objects){ // :TmxObject
			masks_ar.push(object.shapeMask);
#if debug
			debug_graphics_ar.push(object.debug_graphic);
#end
		}

#if debug
		if(debugObjectMask){
			var debug_graphicList = new Graphiclist(debug_graphics_ar);
			this.addGraphic(debug_graphicList);
		}
#end
		
		var maskList = new Masklist(masks_ar);
		this.mask = maskList;
		this.type = typeName;
		
	}

}
