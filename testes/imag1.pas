program type1 (input, output);
var im : imaginario;
    x: integer;
begin
   x := 2;
   im := 2i;
   (* Erros a detectar - n�vel 0*)
   x := im;
   im := x;
end.
