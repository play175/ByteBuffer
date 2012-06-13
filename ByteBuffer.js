/*!
 * ByteBuffer
 * yoyo 2012 https://github.com/play175/ByteBuffer
 * new BSD Licensed
 */

var Type_Byte = 1;
var Type_Short = 2;
var Type_UShort = 3;
var Type_Int32 = 4;
var Type_UInt32 = 5;
var Type_String = 6;//变长字符串，前两个字节表示长度
var Type_VString = 7;//定长字符串
var Type_Int64 = 8;
var Type_Float = 9;
var Type_Double = 10;

var ByteBuffer = function (org_buf,encoding) {

    var _org_buf = org_buf;
    var _encoding = encoding || 'utf8';
    var _offset = 0;
    var _list = [];
    var _offset = 0;

    this.byte = function(val){
        if(val == undefined){
           _list.push(_org_buf.readUInt8(_offset));
           _offset+=1;
        }else{
            _list.push({t:Type_Byte,d:val,l:1});
            _offset += 1;
        }
        return this;
    };

    this.short = function(val){
        if(val == undefined){
           _list.push(_org_buf.readInt16LE(_offset));
           _offset+=2;
        }else{
            _list.push({t:Type_Short,d:val,l:2});
            _offset += 2;
        }
        return this;
    };

    this.ushort = function(val){
        if(val == undefined){
           _list.push(_org_buf.readUInt16LE(_offset));
           _offset+=2;
        }else{
            _list.push({t:Type_UShort,d:val,l:2});
            _offset += 2;
        }
        return this;
    };

    this.int32 = function(val){
        if(val == undefined){
           _list.push(_org_buf.readInt32LE(_offset));
           _offset+=4;
        }else{
            _list.push({t:Type_Int32,d:val,l:4});
            _offset += 4;
        }
        return this;
    };

    this.uint32 = function(val){
        if(val == undefined){
           _list.push(_org_buf.readUInt32LE(_offset));
           _offset+=4;
        }else{
            _list.push({t:Type_UInt32,d:val,l:4});
            _offset += 4;
        }
        return this;
    };

    /**
    * 变长字符串 前2个字节表示字符串长度
    **/
    this.string = function(val){
        if(val == undefined){
           var len = _org_buf.readInt16LE(_offset);
           _offset+=2;
           _list.push(_org_buf.toString(_encoding, _offset, _offset+len));
           _offset+=len;
        }else{
            var len = 0;
            if(val)len = Buffer.byteLength(val, _encoding);
            _list.push({t:Type_String,d:val,l:len});
            _offset += len + 2;
        }
        return this;
    };

    /**
    * 定长字符串 val为null时，读取定长字符串（需指定长度len）
    **/
    this.vstring = function(val,len){
        if(!len){
            throw new Error('vstring must got len argument');
            return this;
        }
        if(val == undefined || val == null){
            var vlen = 0;//实际长度
            for(var i = _offset;i<_offset +len;i++){
                if(_org_buf[i]>0)vlen++;
            }
            _list.push(_org_buf.toString(_encoding, _offset, _offset+vlen));
            _offset+=len;
        }else{
            _list.push({t:Type_VString,d:val,l:len});
            _offset += len;
        }
        return this;
    };

    this.int64 = function(val){
        if(val == undefined){
           _list.push(_org_buf.readDoubleLE(_offset));
           _offset+=8;
        }else{
            _list.push({t:Type_Int64,d:val,l:8});
            _offset += 8;
        }
        return this;
    };

    this.float = function(val){
        if(val == undefined){
           _list.push(_org_buf.readFloatLE(_offset));
           _offset+=4;
        }else{
            _list.push({t:Type_Float,d:val,l:4});
            _offset += 4;
        }
        return this;
    };

    this.double = function(val){
        if(val == undefined){
           _list.push(_org_buf.readDoubleLE(_offset));
           _offset+=8;
        }else{
            _list.push({t:Type_Double,d:val,l:8});
            _offset += 8;
        }
        return this;
    };

    /**
    * 解包成数据数组
    **/
    this.unpack = function(){
        return _list;
    };

    /**
    * 打包成二进制
    **/
    this.pack = function(){
        _org_buf = new Buffer(_offset);
        var offset = 0;
        for (var i = 0; i < _list.length; i++) {
            switch(_list[i].t){
                case Type_Byte:
                    _org_buf.writeUInt8(_list[i].d,offset);
                    offset+=_list[i].l;
                    break;
                case Type_Short:
                    _org_buf.writeInt16LE(_list[i].d,offset);
                    offset+=_list[i].l;
                    break;
                case Type_UShort:
                    _org_buf.writeUInt16LE(_list[i].d,offset);
                    offset+=_list[i].l;
                    break;
                case Type_Int32:
                    _org_buf.writeInt32LE(_list[i].d,offset);
                    offset+=_list[i].l;
                    break;
                case Type_UInt32:
                    _org_buf.writeUInt32LE(_list[i].d,offset);
                    offset+=_list[i].l;
                    break;
                case Type_String:
                    //前2个字节表示字符串长度
                    _org_buf.writeInt16LE(_list[i].l,offset);
                    offset+=2;
                    _org_buf.write(_list[i].d,_encoding,offset);
                    offset+=_list[i].l;
                    break;
                case Type_VString:
                    var vlen = Buffer.byteLength(_list[i].d, _encoding);//字符串实际长度
                    _org_buf.write(_list[i].d,_encoding,offset);
                    //补齐\0
                    for(var j = offset + vlen;j<offset+_list[i].l;j++){
                         _org_buf.writeUInt8(0,j);
                    }
                    offset+=_list[i].l;
                    break;
                case Type_Int64:
                    _org_buf.writeDoubleLE(_list[i].d,offset);
                    offset+=_list[i].l;
                    break;
                case Type_Float:
                    _org_buf.writeFloatLE(_list[i].d,offset);
                    offset+=_list[i].l;
                    break;
                case Type_Double:
                    _org_buf.writeDoubleLE(_list[i].d,offset);
                    offset+=_list[i].l;
                    break;
            }
        }
        return _org_buf;
    };
}

module.exports = exports = ByteBuffer;


/****************************************************************
//压包
var sbuf = new ByteBuffer();
var buffer = sbuf.string('abc123').int32(999).float(0.5).int64(9999999).double(-0.5).pack();
console.log(buffer);

//解包
var rbuf = new ByteBuffer(buffer);
var arr = rbuf.string().int32().float().int64().double().unpack();
console.log(arr);
****************************************************************/