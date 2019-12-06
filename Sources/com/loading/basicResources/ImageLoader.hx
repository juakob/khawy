package com.loading.basicResources;

import kha.Assets;

class ImageLoader extends TilesheetLoader {
	public function new(imageName:String) {
		var description = Reflect.field(Assets.images, imageName + "Description");
		super(imageName, description.original_width, description.original_height, 0);
	}
}
