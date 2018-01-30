--'A' Option 1
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;

package body hash is
   
   function burrisHashFnx (hashKey: hashElem) return Integer is
      tmpUns : unsigned;
   begin
      tmpUns := ((slice2ToUns(hashKey(1..2)) + slice2ToUns(hashKey(6..7)))*256); --shift left 8 bits
      tmpUns := (tmpUns + chrToUns(hashKey(13))) mod 128;                        --first 8 bits above char
      return unsToInt(tmpUns);                                                   --extract first 8 bits
   end burrisHashFnx;
   
   function nsrHashFnx (hashKey : hashElem; TS : Integer) return Integer is
      tmpUns : unsigned;
   begin
      tmpUns := slice8ToUns(hashKey(1..8)) * slice8ToUns(hashKey(9..16)); --square
      tmpUns := (tmpUns / 2**12) mod intToUns(TS);                        --Log2N = TS
      return unsToInt(tmpUns);                                            --extract first N bytes
   end nsrHashFnx;
   
   procedure theory (size:Integer; keys:Integer; probeType:probe) is
      alpha, E: Float;
   begin
      alpha:= (Float(keys) / Float(size));
      if probeType = LINEAR then E:= (1.0 - alpha / 2.0) / (1.0 - alpha);
      else E:= -(1.0 / alpha) * (Log (1.0 - alpha)); end if;
      put_line("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
      put_line("Number of keys:          " & Integer'Image(keys));
      put("Hash table fill percent:  "); 
      floatIO.put(alpha * 100.0, 2, 2, 0); put("%");
      New_Line; put("Average number of probes:"); 
      floatIO.put(E            , 2, 2, 0); New_Line;
   end theory;
   
   procedure avgStor (input:hReadIO.File_Type; output:hRecdIO.File_Type; nsrTable:hashTabl; lower:Integer;
                     upper:Integer; size:Integer; probeType:probe; hFnxType:hashFnx; storeType:storage) is
      min: Integer := 1000;
      max: Integer := 1;
      avg: Float := 0.0;
      div: Float := Float(upper-lower+1);
   begin
      for i in lower..upper loop
         declare
            tmpHRecOut1, tmpHRecOut2: hashRecd;
            tmpHashRead: hashRead;
            offset, loc: Integer:= 0;
            R:           Integer:= 1;
            divisor:     Integer:= 2**(Integer(Log(Base => 2.0, X => Float(size))) + 2);
         begin
            -- read input and slice out keys
            Read(input, tmpHashRead, hReadIO.Count(i)); tmpHRecOut1.key := tmpHashRead(1..16);
            
            -- use hash function: burris or else nsr
            if hFnxType = burris then
               tmpHRecOut1.addr := burrisHashFnx(tmpHRecOut1.key);
            else
               tmpHRecOut1.addr := nsrHashFnx(tmpHRecOut1.key, size);
            end if;
            
            -- store table in relative file
            if storeType = file then
               
               -- find empty space
               loop
                  loc := (tmpHRecOut1.addr + offset) mod size;
                  if loc = 0 then loc := 64; end if; --fix wrap around
                  hRecdIO.Read(output, tmpHRecOut2, hRecdIO.Count(loc));
                  exit when tmpHRecOut2.key = tmpHRecOut1.key;
                  tmpHRecOut1.probes := tmpHRecOut1.probes + 1;
                  
                  -- use probe type: linear or else random
                  if probeType = LINEAR then offset := offset + 1;
                  else R := (R * 5) mod divisor; offset := R / 4; end if;
               end loop;
            
            -- store hash table in main memory
            else
               while nsrTable((tmpHRecOut1.addr + offset) mod size).key /= tmpHRecOut1.key loop
                  
                  -- use probe type: linear or else random
                  if probeType = LINEAR then offset := offset + 1;
                  else R := (R * 5) mod divisor; offset := R/4; end if;
                  tmpHRecOut1.probes := tmpHRecOut1.probes + 1;
               end loop;
            end if;
            
            -- updating min, max and avg probes
            if    tmpHRecOut1.probes < min then min:= tmpHRecOut1.probes;
            elsif tmpHRecOut1.probes > max then max:= tmpHRecOut1.probes; end if;
            avg := avg + (Float(tmpHRecOut1.probes) / div);
         end;
      end loop;
      
      --print results
      put_line("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
      put_line("Probe statistic of range:" & Integer'Image(lower) & " to" & Integer'Image(upper));
      put_line("Minimum number of probes:" & Integer'Image(min));
      put_line("Maximum number of probes:" & Integer'Image(max));
      put("Average number of probes:"); floatIO.put(avg, 3, 2, 0); New_Line;
   end avgStor;
   
   procedure process (inFileName:String; outFileName:String; size:Integer; prctFull:Float; probeType:probe; hFnxType:hashFnx; storeType:storage) is
   begin
      --put_line("Probe Type:    " & probe'Image(probeType)); put_line("Hash Function: " & hashFnx'Image (hFnxType));
      
      -- store has table in: relative file or else main memory
      if storeType = memory then          			--put_line("Stored in:     MAIN MEMORY");
         mainMem(inFileName,              size, prctFull, probeType, hFnxType);
      else                               			--put_line("Stored in:     " & outFileName);
         relFile(inFileName, outFileName, size, prctFull, probeType, hFnxType);
      end if;
   end process;

   procedure relFile (inFileName:String; outFileName:String; size:Integer; prctFull:Float; probeType:probe; hFnxType:hashFnx) is
      input:  hReadIO.File_Type;
      output: hRecdIO.File_Type;
      tmpHRecdOut: hashRecd;
      loc:   Integer;
      upper: Integer := Integer(Float'Floor(Float(size) * prctFull));
   begin
      Open(input, in_file, inFileName);
      declare
         nullRec: hashRecd:= ("                ", 0, 0);
      begin
         Create(output, inout_file, outFileName);
         for i in 1..size loop hRecdIO.Write(output, nullRec, hRecdIO.Count(i)); end loop;
         for i in 2..upper+1 loop
            declare
               tmpHashRecd: hashRecd;
               tmpHashRead: hashRead;
               offset:  Integer:= 0;
               R:       Integer:= 1;
               divisor: Integer:= 2**(Integer(Log(Base => 2.0, X => Float(size))) + 2);
            begin
                -- read input and slice out keys
               hReadIO.Read(input, tmpHashRead, hReadIO.Count(i)); tmpHashRecd.key:= tmpHashRead(1..16);
               
               -- use hash function: burris or else nsr
               if hFnxType = burris then tmpHashRecd.addr := burrisHashFnx(tmpHashRecd.key);
               else tmpHashRecd.addr := nsrHashFnx(tmpHashRecd.key, size); end if;
               
               -- find empty space in file
               loop
                  loc := (tmpHashRecd.addr + offset) mod size;
                  if loc = 0 then loc := 64; end if; -- fix wrap around
                  hRecdIO.Read(output, tmpHRecdOut, hRecdIO.Count(loc));
                  exit when tmpHRecdOut = nullRec;
                  tmpHashRecd.probes := tmpHashRecd.probes + 1;
                  
                  -- use probe type: linear or else random
                  if probeType = LINEAR then offset := offset + 1;
                  else R := (R * 5) mod divisor; offset := R / 4; end if;
               end loop;
               hRecdIO.Write(output, tmpHashRecd, hRecdIO.Count(loc));
            end;
         end loop;
         
         -- read to temp hash record (tmpHRecdOut) to print results
         for i in 1..size loop hRecdIO.Read(output, tmpHRecdOut, hRecdIO.Count(i));
            if tmpHRecdOut /= nullRec then
               put(Integer'Image(i) & ": "); put(tmpHRecdOut.key); 
               put("Was stored in:" & Integer'Image(tmpHRecdOut.addr));
               put("     Probes:" & Integer'Image(tmpHRecdOut.probes)); New_Line;
            else
               put_line(Integer'Image(i) & ": null");
            end if;
         end loop;
         
         avgStor(input, output, eTable, 2,           31, size, probeType, hFnxType, file);
         avgStor(input, output, eTable, upper-29, upper, size, probeType, hFnxType, file); 
         theory(size, upper, probeType); New_Line; Close(output);
      end;
      Close(input);
   end relFile;
   
   procedure mainMem (inFileName:String; size:Integer; prctFull:Float; probeType:probe; hFnxType:hashFnx) is
      input: hReadIO.File_Type;
      upper: Integer:= Integer(Float'Floor(Float(size) * prctFull));     
   begin
      Open(input, in_file, inFileName); Reset(input);
      declare
         nullRec: hashRecd := (key => "                ", addr => 0, probes => 0);
         nsrTable: hashTabl (0..size-1):= (others => nullRec);
      begin
         for i in 2..upper+1 loop
            declare
               tmpHashRecd: hashRecd;
               tmpHashRead: hashRead;
               offset: Integer := 0;
               R:      Integer := 1;
               div:    Integer := 2**(Integer(Log(Base => 2.0, X => Float(size))) + 2);
            begin
               -- read input and slice out keys
               Read(input, tmpHashRead, hReadIO.Count(i)); tmpHashRecd.key:= tmpHashRead(1..16);
               
               -- use hash function: burris or else nsr
               if hFnxType = burris then tmpHashRecd.addr:= burrisHashFnx(tmpHashRecd.key);
               else tmpHashRecd.addr := nsrHashFnx(tmpHashRecd.key, size); end if;
               
               while nsrTable((tmpHashRecd.addr + offset) mod size).key /= nullRec.key loop
                  
                  -- use probe type: linear or else random
                  if probeType = LINEAR then offset := offset + 1;
                  else R := (R * 5) mod div; offset := (R / 4); end if;
                  tmpHashRecd.probes := tmpHashRecd.probes + 1;
               end loop;
               nsrTable((tmpHashRecd.addr + offset) mod size) := tmpHashRecd;
            end;
         end loop;
                  
         -- directly use hash table to print results
         for i in 0..size-1 loop
            if nsrTable(i).key /= nullRec.key then
               put(Integer'Image(i) & ": "); put(nsrTable(i).key); 
               put("Was stored in:" & Integer'Image(nsrTable(i).addr));
               put("     Probes:" & Integer'Image(nsrTable(i).probes)); New_Line;
            else
               put_line(Integer'Image(i) & ": null");
            end if;
         end loop; 

         avgStor(input, eFile, nsrTable, 2,           31, size, probeType, hFnxType, memory);
         avgStor(input, eFile, nsrTable, upper-29, upper, size, probeType, hFnxType, memory); 
         theory(size, upper, probeType); New_Line;
      end;
      Close(input);
   end mainMem;   
   
end hash;
