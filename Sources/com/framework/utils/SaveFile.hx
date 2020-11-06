package com.framework.utils;
 import js.lib.DataView;
import js.lib.ArrayBuffer;
import js.html.FileReader;
import js.html.Attr;
import js.html.InputElement;
import haxe.io.Bytes;
#if js
    import js.Browser;
    import js.html.Blob;
    import js.html.URL;
    import js.html.AnchorElement;
    #end
class SaveFile {
   
    private static function _saveBytes(bytes:Bytes, name:String , type:String )
        {
          #if js
          var a = Browser.document.createAnchorElement();
          var blob = new Blob([bytes.getData()], {type: type});
          var url = URL.createObjectURL(blob);
      
          a.href = url;
          a.download = name;
          Browser.document.body.appendChild(a);
      
          a.click();
      
          Browser.window.setTimeout(function()
          {
            Browser.document.body.removeChild(a);
            URL.revokeObjectURL(url);
          }, 0);
          #end
          
          trace("Saved");
        }
        public static function saveBytes(bytes:Bytes, name:String , type:String )
        {
          _saveBytes(bytes, name, type);
        }
       
        public static function openFile(onRead:StreamReader->Void) {
          var input:InputElement =  Browser.document.createInputElement();
          input.type="file";
          input.onchange=function handleFile() {
            var reader = new FileReader();
            reader.onload = function() {
              var arrayBuffer:ArrayBuffer =cast reader.result;
              var dataView=new DataView(arrayBuffer);
              onRead(new StreamReader(dataView));
            }
            reader.readAsArrayBuffer(input.files[0]);
          }
          input.click();

         //input.op
          //input.attributes.setNamedItem({"type", "file"});
          // add onchange handler if you wish to get the file :)
          //input.tr("click"); // opening dialog
          return false; // avoiding navigation
        }
       
}
class StreamReader {
  var data:DataView;
  var offset:Int;
  
  public function new(data:DataView) {
    this.data=data;
    offset=0;
  }
  public function readInt32() {
    var value=data.getInt32(offset,true);
    offset+=4;
    return value;
  }
  public function readFloat() {
    var value=data.getFloat32(offset,true);
    offset+=4;
    return value;
  }
  public function finish() {
    return data.byteLength==offset;
  }
}