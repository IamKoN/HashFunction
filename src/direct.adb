with direct_io, text_io;
procedure makeDirect is
   package IIO is new text_io.integer_io(integer); use IIO;
   type newRec is record
      int:integer;
      str5:string(1..5);
   end record;

   -- positive_count in direct_io;
   rec1: newRec;
   newFile: file_type;
   posPt: positive_count;
   j:  integer := 0;

begin
   create(newFile, inout_file, "directFile"); rec1.a := "abcde"; reset(newFile);
   for posPt in positive_count range 1..10 loop
      j:= j + 1;
      rec1.int:= j;
      write(newFile, rec1, posPt);
   end loop;
   close(newFile);

   open(newFile, inout_file,"directFile"); reset(newFile);
   for posPt in positive_count range 1..10 loop
      read(newFile, rec1, posPt);
      text_io.put(rec1.str5);
      IIO.put(rec1.int);
      text_io.new_line;
   end loop;
   close(newFile);
end makeDirect;
