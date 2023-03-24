library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity fill_Screen is	
			port( clk: in std_logic;
					resetn: in std_logic;
					plot: out std_logic;
					x: out std_logic_vector(7 downto 0);
					y: out std_logic_vector(6 downto 0);
					colour: out std_logic_vector(2 downto 0));
end fill_Screen;

Architecture behaviuor of fill_screen is

	signal finish: std_logic:='0';
	signal start: std_logic:='1';
	begin
	
	process(clk,resetn,finish,start)
	variable xTemp: unsigned(7 downto 0);
	variable yTemp: unsigned(6 downto 0);
	variable plotTemp: std_logic;
	variable colourTemp: unsigned(2 downto 0);
	begin
		if(rising_edge(clk)) then
				
				if (resetn='0') then
					xTemp:= "00000000";
					yTemp:="0000000";
					plotTemp:='0';
					colourTemp:="000";
				end if;
				
				if (finish='1') then
					plotTemp:='0';
				end if;
				
				if (start='1') then
					plotTemp:='1';
					finish<='0';
					
					if (xTemp<160) then
						xTemp:=xTemp+"00000001";
						colourTemp := (unsigned(xTemp mod 8)(2 downto 0));
					else 
						yTemp:=yTemp+"0000001";
						xTemp:="00000000";
					end if;
					
					if (yTemp=119) then
						finish<='1';
						start<='0';
					end if;
					
				end if;
				
				x<=std_logic_vector(xTemp);
				y<=std_logic_vector(yTemp);
				colour<=std_logic_vector(colourTemp(2 downto 0));
				plot<=plotTemp;
				
			end if;	
	end process;
End;