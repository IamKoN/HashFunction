--'A' Option 1
with Ada.Text_IO, direct_io; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with hash; use hash;

procedure usehash is
   
   inFileName: String := "Words200D16.txt";
   
begin
   
--   put_line("--- Part A (50% full, linear probe, burHash): C Option (main memory) ---");
--   hash.process (inFileName, "null", 128, 0.5, linear, burris, memory);
   
--   put_line("--- Part A (50% full, linear probe, burHash): B Option (relative file) ---");
--   hash.process (inFileName, "A5LB", 128, 0.5, linear, burris, file);

--   put_line("--- Part B (90% full, linear probe, burHash): C Option (main memory) ---");
--   hash.process (inFileName, "null", 128, 0.9, linear, burris, memory);
   
--   put_line("--- Part B (90% full, linear probe, burHash): B Option (relative file) ---");
--   hash.process (inFileName, "B9LB", 128, 0.9, linear, burris, file);

--   put_line("--- Part C (50% full, random probe, burHash): C Option (main memory) ---");
--   hash.process (inFileName, "null", 128, 0.5, random, burris, memory);
   
--   put_line("--- Part C (90% full, random probe, burHash): C Option (main memory) ---");
--   hash.process (inFileName, "null", 128, 0.9, random, burris, memory);
   
--   put_line("--- Part C (50% full, random probe, burHash): B Option (relative file) ---");
--   hash.process (inFileName, "C5RB", 128, 0.5, random, burris, file);
   
--   put_line("--- Part C (90% full, random probe, burHash): B Option (relative file) ---");
--   hash.process (inFileName, "C9RB", 128, 0.9, random, burris, file);

--   put_line("--- Part E (50% full, linear probe, nsrHash): C Option (main memory) ---");
--   hash.process (inFileName, "null", 128, 0.5, linear, nsr, memory);
   
--   put_line("--- Part E (90% full, linear probe, nsrHash): C Option (main memory) ---");
--   hash.process (inFileName, "null", 128, 0.9, linear, nsr, memory);

--   put_line("--- Part E (50% full, random probe, nsrHash): C Option (main memory) ---");
--   hash.process (inFileName, "null", 128, 0.5, random, nsr, memory);

--   put_line("--- Part E (90% full, random probe, nsrHash): C Option (main memory) ---");
--   hash.process (inFileName, "null", 128, 0.9, random, nsr, memory);
   
--   put_line("--- Part E (50% full, linear probe, nsrHash): B Option (relative file) ---");
--   hash.process (inFileName, "E5LN", 128, 0.5, linear, nsr, file);
   
--   put_line("--- Part E (90% full, linear probe, nsrHash): B Option (relative file) ---");
--   hash.process (inFileName, "E9LN", 128, 0.9, linear, nsr, file);

--   put_line("--- Part E (50% full, random probe, nsrHash): B Option (relative file) ---");
--   hash.process (inFileName, "E5RN", 128, 0.5, random, nsr, file);

--   put_line("--- Part E (90% full, random probe, nsrHash): B Option (relative file) ---");
--   hash.process (inFileName, "E9RN", 128, 0.9, random, nsr, file);
end usehash;
