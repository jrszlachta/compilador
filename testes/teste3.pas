program exemplo75 (input, output) ;
var m :  integer; n : integer; o : integer; p : integer;
begin
  n := 3;
  m := 5;
  p := m + n * (n);
  o := m > n or p < n and m > p;
  o := 5 + 2 < 3 and ( 1 = 1 or 2 > 3);
end.
