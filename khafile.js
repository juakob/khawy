let project = new Project('khawy');

project.addAssets('Assets/**');
project.addShaders('Shaders/**');
project.addLibrary('hxGeomAlgo');
project.addLibrary('Format');
project.addSources('Sources');

resolve(project);
