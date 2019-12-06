package com.g3d;

import kha.Image;
import kha.Blob;
import com.loading.Resource;
import kha.Assets;

class Object3dLoader implements Resource {
	var name:String;
	var onLoad:Void->Void;
	var neededResources:Int = 0;
	var data:OgexData;

	public function new(dataName:String) {
		name = dataName;
	}

	public function load(callback:Void->Void):Void {
		onLoad = callback;
		++neededResources;
		Assets.loadBlob(name, loadBlob);
	}

	public function loadLocal(callback:Void->Void):Void {
		onLoad = callback;
		++neededResources;
		loadBlob(cast Reflect.field(Assets.blobs, name));
	}

	function loadBlob(b:Blob) {
		data = new OgexData(b.toString());
		for (material in data.materials) {
			for (tex in material.texture) {
				++neededResources;
				var parts = tex.path.split("/");
				var ss = parts[parts.length - 1];
				ss = StringTools.replace(ss, "-", "_");
				ss = StringTools.replace(ss, " ", "_");
				Assets.loadImage(ss.split(".")[0], function(i) {
					somthingLoaded();
				});
			}
		}
		somthingLoaded();
	}

	function somthingLoaded() {
		--neededResources;
		if (neededResources <= 0) {
			var sk = SkeletonLoader.getSkeleton(data);
			var obj3d = MeshExtractor.extract(data, sk);
			Object3dDB.i.add(name, obj3d);
			if (sk.length > 0) {
				sk[0].setFrame(0);
				Object3dDB.i.addSkeleton(name, sk[0]);
			}

			onLoad();
		}
	}

	public function unload():Void {
		Reflect.callMethod(Assets.blobs, Reflect.field(Assets.blobs, name + "Unload"), []);
	}

	public function unloadLocal():Void {}
}
