program type2 (input, output);
var im : imaginario;
    x: integer;

function f (im1 : imaginario):imaginario;
begin
   f := im1 + 2i
end;


begin
   x := 2;
   im := f(2i);
   (* Erros a detectar - nível 1 *)
   if (x = im) then
      x := 1;
end.
