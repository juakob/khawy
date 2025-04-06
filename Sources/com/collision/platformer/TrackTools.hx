package com.collision.platformer;

class TrackTools {

    public static function getTracksFromTilemap(map:CollisionTileMap) {
        var collisions:CollisionGroup = new CollisionGroup();
        var startX:Int=0;
        var creatingTop:Bool =false;
        var edges:Array<Track> = new Array();
        
        for(y in 0...map.heightInTiles){
            for(x in 0...map.widthIntTiles){
                var edge = map.edgeType(x,y);
                
                if(edge & Sides.TOP>0){
                    if(!creatingTop){
                        startX=x;
                        creatingTop=true;
                    }
                }else
                if(creatingTop){
                    var edge=new Track(startX*map.tileWidth,y*map.tileHeight,(x)*map.tileWidth,y*map.tileHeight);
                    collisions.add(edge);
                    edges.push(edge);
                    creatingTop=false;
                }
            }
            if(creatingTop){
                var edge=new Track(startX*map.tileWidth,y*map.tileHeight,(map.widthIntTiles)*map.tileWidth,y*map.tileHeight);
                collisions.add(edge);
                edges.push(edge);
                creatingTop=false;
            }
        }

        var startY:Int=0;
        var creatingSide:Bool =false;
        for(x in 0...map.widthIntTiles){ 
                for(y in 0...map.heightInTiles){

                var edge = map.edgeType(x,y);
                
                if(edge & Sides.RIGHT>0){
                    if(!creatingSide){
                        startY=y;
                        creatingSide=true;
                    }
                }else
                if(creatingSide){
                    var edge=new Track((x+1)*map.tileWidth,startY*map.tileHeight,(x+1)*map.tileWidth,y*map.tileHeight);
                    edge.isWall=true;
                    collisions.add(edge);
                    edges.push(edge);
                    creatingSide=false;
                }
            }
            if(creatingSide){
                var edge=new Track((x+1)*map.tileWidth,startY*map.tileHeight,(x+1)*map.tileWidth,map.heightInTiles*map.tileHeight);
                collisions.add(edge);
                edges.push(edge);
                creatingSide=false;
            }
        }
        var counter=0;
        for (a in edges) {
            ++counter;
            for (index in counter...edges.length){
                var b=edges[index];
                if((b.pos.x==a.pos.x && b.pos.y==a.pos.y)){
                    if(a.isWall){
                        a.nextEdge=b;
                        b.prevEdge=a;
                    }else{
                        b.nextEdge=a;
                        a.prevEdge=b;
                    }
                }else 
                if(b.dir.x*b.length+b.pos.x==a.pos.x && b.dir.y*b.length+b.pos.y==a.pos.y){
                    b.nextEdge=a;
                    a.prevEdge=b;
                }else 
                if(b.pos.x==a.pos.x+a.dir.x*a.length && b.pos.y==a.pos.y+a.dir.y*a.length){
                    a.nextEdge=b;
                    b.prevEdge=a;
                }else 
                if(b.pos.x+b.dir.x*b.length==a.pos.x+a.dir.x*a.length && b.pos.y+b.dir.y*b.length==a.pos.y+a.dir.y*a.length){
                    if(a.isWall){
                        a.nextEdge=b;
                        b.prevEdge=a;
                    }else{
                        b.nextEdge=a;
                        a.prevEdge=b;
                    }
                }
            }
           
        }
        return collisions;
    }
}