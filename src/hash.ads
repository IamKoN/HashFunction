--'A' Option 1
with Ada.Text_IO; use Ada.Text_IO;
with direct_io;
with Ada.Unchecked_Conversion;

package hash is
   subtype outStr   is String(1..25);
   subtype hashRead is String(1..18);
   subtype hashElem is String(1..16);
   subtype slice8   is String(1..8);
   subtype slice2   is String(1..2);

   type unsigned is mod 2**64;
   type storage is (memory, file);
   type probe is (linear, random);
   type hashFnx is (nsr, burris);
   type hashRecd is record
      key:    hashElem;
      addr:   Integer;
      probes: Integer:= 1;
   end record;
   type hashTabl is array (Integer range <>) of hashRecd;
   
   package floatIO is new Float_IO(Float);     use floatIO;
   package hReadIO is new Direct_IO(hashRead); use hReadIO;
   package hRecdIO is new Direct_IO(hashRecd); use hRecdIO;
   
   eFile:  hRecdIO.File_Type;
   eTable: hashTabl(1..2);
   
   function slice2ToUns is new Ada.Unchecked_Conversion(slice2, unsigned);
   function slice8ToUns is new Ada.Unchecked_Conversion(slice8, unsigned);
   function chrToUns is new Ada.Unchecked_Conversion(character, unsigned);
   function intToUns is new Ada.Unchecked_Conversion(Integer,   unsigned);
   function unsToInt is new Ada.Unchecked_Conversion(unsigned,  Integer);
   
   function burrisHashFnx (hashKey:hashElem)             return Integer;
   function nsrHashFnx    (hashKey:hashElem; TS:Integer) return Integer;
   
   procedure theory  (size:Integer;keys:Integer;probeType:probe);
   procedure avgStor  (input:hReadIO.File_Type; output:hRecdIO.File_Type;nsrTable:hashTabl;lower:Integer;upper:Integer;
                                                           size:Integer;               probeType:probe;hFnxType:hashFnx;storeType:storage);
   procedure process (inFileName:String;outFileName:String;size:Integer;prctFull:Float;probeType:probe;hFnxType:hashFnx;storeType:storage);
   procedure relFile (inFileName:String;outFileName:String;size:Integer;prctFull:Float;probeType:probe;hFnxType:hashFnx);
   procedure mainMem (inFileName:String;                   size:Integer;prctFull:Float;probeType:probe;hFnxType:hashFnx);

end hash;
