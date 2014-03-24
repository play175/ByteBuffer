package  
{
	import flash.utils.*;
	
	/**
	 * ByteBuffer对应的as版本
	 * sample code:
		//压包操作
		var sbuf:ByteBuffer = new ByteBuffer();
		var ba:ByteArray = new ByteArray();
		ba.writeMultiByte('123vstring','utf-8');
		ba.position = 0;
		var buffer:ByteArray = sbuf.string('abc123你好')//变长字符串，前两个字节表示长度
							   .int32(-999).uint32(999).float(-0.5)
							   .int64(9999999).double(-0.000005).short(32767).ushort(65535)
							   .byte(255)
							   .vstring('abcd',5)//定长字符串,不足的字节补0x00
							   .byteArray(ba,10)//字节数组，不足字节补0x00
							   .pack();//结尾调用打包方法

		trace(buffer);
		
		//解包操作
		var rbuf:ByteBuffer = new ByteBuffer(buffer);
		//解包出来是一个数组
		var arr:Array = rbuf.string()//变长字符串，前两个字节表示长度
							.int32().uint32().float()
							.int64().double().short().ushort()
							.byte()
							.vstring(null,5)//定长字符串,不足的字节补0x00
							.byteArray(null,10)//字节数组，不足字节补0x00
							.unpack();//结尾调用解包方法

		trace(arr);
	 * @author yoyo 2014 https://github.com/play175/ByteBuffer
	 */
	public class ByteBuffer 
	{
		public static const Type_Byte:int = 1;
		public static const Type_Short:int = 2;
		public static const Type_UShort:int = 3;
		public static const Type_Int32:int = 4;
		public static const Type_UInt32:int = 5;
		public static const Type_String:int = 6;//变长字符串，前两个字节表示长度
		public static const Type_VString:int = 7;//定长字符串
		public static const Type_Int64:int = 8;
		public static const Type_Float:int = 9;
		public static const Type_Double:int = 10;
		public static const Type_ByteArray:int = 11;

		
		private var _org_buf:ByteArray;
		private var _encoding:String = 'utf-8';
		private var _offset:int;
		private var _list:Array = [];
		private var _endian:String = 'B';

		public function ByteBuffer(org_buf:ByteArray = null,offset:int = 0) 
		{
			_org_buf = org_buf;
			_offset = offset || 0;
			setEndian();
		}
		
		/**指定文字编码**/
		public function encoding (encode:String):ByteBuffer{
			_encoding = encode;
			return this;
		}
		
		private function setEndian(ba:ByteArray = null):void
		{
			if (ba == null) ba = _org_buf;
		   if (ba)ba.endian = _endian == 'B'?Endian.BIG_ENDIAN:Endian.LITTLE_ENDIAN;
		}
    
		/**指定字节序 为BigEndian**/
		public function bigEndian ():ByteBuffer{
		   _endian = 'B';
		   setEndian();
			return this;
		}

		/**指定字节序 为LittleEndian**/
		public function littleEndian ():ByteBuffer{
		   _endian = 'L';
		   setEndian();
			return this;
		}

		public function byte (val:int = undefined,index:int = undefined):ByteBuffer{
			if (arguments.length == 0) {
				_org_buf.position = _offset;
			   _list.push(_org_buf.readByte());
			   _offset+=1;
			}else{
				_list.splice((arguments.length >= 2) ? index : _list.length,0,{t:Type_Byte,d:val,l:1});
				_offset += 1;
			}
			return this;
		}

		public function short (val:int = undefined,index:int = undefined):ByteBuffer{
			if(arguments.length == 0){
				_org_buf.position = _offset;
			   _list.push(_org_buf.readShort());
			   _offset+=2;
			}else{
				_list.splice((arguments.length >= 2) ? index : _list.length,0,{t:Type_Short,d:val,l:2});
				_offset += 2;
			}
			return this;
		}

		public function ushort (val:int = undefined,index:int = undefined):ByteBuffer{
			if(arguments.length == 0){
				_org_buf.position = _offset;
			   _list.push(_org_buf.readUnsignedShort());
			   _offset+=2;
			}else{
				_list.splice((arguments.length >= 2) ? index : _list.length,0,{t:Type_UShort,d:val,l:2});
				_offset += 2;
			}
			return this;
		}

		public function int32 (val:int = undefined,index:int = undefined):ByteBuffer{
			if(arguments.length == 0){
				_org_buf.position = _offset;
			   _list.push(_org_buf.readInt());
			   _offset+=4;
			}else{
				_list.splice((arguments.length >= 2) ? index : _list.length,0,{t:Type_Int32,d:val,l:4});
				_offset += 4;
			}
			return this;
		}

		public function uint32 (val:int = undefined,index:int = undefined):ByteBuffer{
			if(arguments.length == 0){
				_org_buf.position = _offset;
			   _list.push(_org_buf.readUnsignedInt());
			   _offset+=4;
			}else{
				_list.splice((arguments.length >= 2) ? index : _list.length,0,{t:Type_UInt32,d:val,l:4});
				_offset += 4;
			}
			return this;
		}

		/**
		* 变长字符串 前2个字节表示字符串长度
		**/
		public function string (val:String = undefined,index:int = undefined):ByteBuffer{
			var len:int = 0;
			if(!val){
				_org_buf.position = _offset;
			   len = _org_buf.readUnsignedShort();
			   _offset+=2;
				_org_buf.position = _offset;
			   _list.push(_org_buf.readMultiByte(len,_encoding));
			   _offset+=len;
			}else{
				len = stringByteLen(val);
				_list.splice((arguments.length >= 2) ? index : _list.length,0,{t:Type_String,d:val,l:len});
				_offset += len + 2;
			}
			return this;
		}

		/**
		* 定长字符串 val为null时，读取定长字符串（需指定长度len）
		**/
		public function vstring (val:String = undefined,len:int = undefined,index:int = undefined):ByteBuffer{
			if(!val){
				_org_buf.position = _offset;
			   _list.push(_org_buf.readMultiByte(len,_encoding));
				_offset+=len;
			}else{
				_list.splice((arguments.length >= 3) ? index : _list.length,0,{t:Type_VString,d:val,l:len});
				_offset += len;
			}
			return this;
		}

		public function int64 (val:Number = undefined,index:int = undefined):ByteBuffer{
			if(arguments.length == 0){
				_org_buf.position = _offset;
			   _list.push(_org_buf.readDouble());
			   _offset+=8;
			}else{
				_list.splice((arguments.length >= 2) ? index : _list.length,0,{t:Type_Int64,d:val,l:8});
				_offset += 8;
			}
			return this;
		}

		public function float (val:Number = undefined,index:int = undefined):ByteBuffer{
			if(arguments.length == 0){
				_org_buf.position = _offset;
			   _list.push(_org_buf.readFloat());
			   _offset+=4;
			}else{
				_list.splice((arguments.length >= 2) ? index : _list.length,0,{t:Type_Float,d:val,l:4});
				_offset += 4;
			}
			return this;
		}

		public function double (val:Number = undefined,index:int = undefined):ByteBuffer{
			if(arguments.length == 0){
				_org_buf.position = _offset;
			   _list.push(_org_buf.readDouble());
			   _offset+=8;
			}else{
				_list.splice((arguments.length >= 2) ? index : _list.length,0,{t:Type_Double,d:val,l:8});
				_offset += 8;
			}
			return this;
		}
		
		/**
		* 写入或读取一段字节数组
		**/
		public function byteArray (val:ByteArray = undefined,len:int = undefined,index:int = undefined):ByteBuffer{
			 var arr:ByteArray;
			if(!val){
				_org_buf.position = _offset;
				arr = new ByteArray();
				setEndian(arr);
				arr.position = 0;
				_org_buf.readBytes(arr, 0, len);
				_list.push(arr);
			   _offset+=len;
			}else {
				//拷贝字节数组
				arr = new ByteArray();
				setEndian(arr);
				arr.position = 0;
				arr.writeBytes(val, val.position, val.bytesAvailable);
				arr.position = 0;
				_list.splice((arguments.length >= 3) ? index : _list.length,0,{t:Type_ByteArray,d:arr,l:len});
				_offset += len;
			}
			return this;
		}

		/**
		* 解包成数据数组
		**/
		public function unpack ():Array{
			return _list;
		}
		
		/**
		* 打包成二进制,在前面加上2个字节表示包长
		**/
		public function packWithHead ():ByteArray {
			return pack(true);
		}

		/**
		* 打包成二进制
		* @param ifHead 是否在前面加上2个字节表示包长
		**/
		public function pack (ifHead:Boolean = false):ByteArray{
			_org_buf = new ByteArray();
			setEndian();
			_org_buf.position = 0;
			if(ifHead){
				_org_buf.writeShort(_offset);
			}
			var i:int, j:int,end:int;
			for (i = 0; i < _list.length; i++) {
				switch(_list[i].t){
					case Type_Byte:
						_org_buf.writeByte(_list[i].d);
						break;
					case Type_Short:
						_org_buf.writeShort(_list[i].d);
						break;
					case Type_UShort:
						_org_buf.writeShort(_list[i].d);
						break;
					case Type_Int32:
						_org_buf.writeInt(_list[i].d);
						break;
					case Type_UInt32:
						_org_buf.writeUnsignedInt(_list[i].d);
						break;
					case Type_String:
						//前2个字节表示字符串长度
						_org_buf.writeShort(_list[i].l);
						_org_buf.writeMultiByte(_list[i].d, _encoding);
						break;
					case Type_VString:
						var vlen:int = stringByteLen(_list[i].d);//字符串实际长度
						_org_buf.writeMultiByte(_list[i].d, _encoding);
						//补齐\0
						for(j = _org_buf.position,end = _org_buf.position + (_list[i].l - vlen);j<end;j++) {
							 _org_buf.writeByte(0);
						}
						break;
					case Type_Int64:
						_org_buf.writeDouble(_list[i].d);
						break;
					case Type_Float:
						_org_buf.writeFloat(_list[i].d);
						break;
					case Type_Double:
						_org_buf.writeDouble(_list[i].d);
						break;
					case Type_ByteArray:
						_org_buf.writeBytes(_list[i].d, 0, _list[i].d.length);
						for(j = _org_buf.position,end = _org_buf.position + (_list[i].l - _list[i].d.length);j<end;j++){
							 _org_buf.writeByte(0);
						}
						break;
				}
			}
			_org_buf.position = 0;
			return _org_buf;
		}
    
		 /**
		* 未读数据长度
		**/
		public function getAvailable ():int{
			if(!_org_buf)return _offset;
			return _org_buf.length - _offset;
		}
		
		public function stringByteLen(txtStr:String):int {
			if(txtStr == null) return 0;
			var bytes:ByteArray = new ByteArray();
			bytes.writeMultiByte(txtStr,_encoding);
			return bytes.length;
		}
	}

}