program exemplo75 (input, output) ;
var m,n :  integer;
	   p : integer;
begin
	m := n;
	p := 0;
	if m > n then
	begin
		p := p + 1;
		if m < n then
		begin
			p := p - 1
		end
		else
		begin
			m := m + n
		end
	end
end.
