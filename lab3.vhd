library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lab3 is
  port(CLOCK_50            : in  std_logic;
       KEY                 : in  std_logic_vector(3 downto 0);
       SW                  : in  std_logic_vector(17 downto 0);
       VGA_R, VGA_G, VGA_B : out std_logic_vector(9 downto 0);  -- The outs go to VGA controller
       VGA_HS              : out std_logic;
       VGA_VS              : out std_logic;
       VGA_BLANK           : out std_logic;
       VGA_SYNC            : out std_logic;
       VGA_CLK             : out std_logic);
end lab3;

architecture rtl of lab3 is

  component vga_adapter
		generic(RESOLUTION : string);
		 port (resetn                                       : in  std_logic;
				 clock                                        : in  std_logic;
				 colour                                       : in  std_logic_vector(2 downto 0);
				 x                                            : in  std_logic_vector(7 downto 0);
				 y                                            : in  std_logic_vector(6 downto 0);
				 plot                                         : in  std_logic;
				 VGA_R, VGA_G, VGA_B                          : out std_logic_vector(9 downto 0);
				 VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK : out std_logic);
  end component;
---------------------------------------------------------------------------------------------------------  
  component fill_Screen is	
			port( clk: in std_logic;
					resetn: in std_logic;
					plot: out std_logic;
					x: out std_logic_vector(7 downto 0);
					y: out std_logic_vector(6 downto 0);
					colour: out std_logic_vector(2 downto 0));
 end component;
 ----------------------------------------------------------------------------------------------------------
  signal dx,dy: integer ;
  signal sx,sy: integer ;
  signal err, e2: integer ;
  signal x: std_logic_vector(7 downto 0);
  signal y: std_logic_vector(6 downto 0);
  signal x0,y0,x1,y1: integer :=0;
  signal colour : std_logic_vector(2 downto 0);
  signal plot   : std_logic;
  signal itr : integer range 1 to 14:=1;
  signal c: integer;
  signal counter: integer;
  signal flag: std_logic:='0';
  SIGNAL xTemp,yTemp: integer:=0;
  
	
  type states is (S0,S1,S2,S3,S4,S5,STATE_WAIT,STATE_ERASE_1,STATE_ERASE_2);
--  type states is (S0,S1,S2,S3,S4,S5,STATE_WAIT);
  signal state : states;

begin
				
	process(clock_50,key(3))
			
		begin
			
			if (key(3)='0') then
				colour<="000";
				x<="00000000";
				y<="0000000";
				plot<='0';
				itr<=1;
				x0<=0;
				y0<=0;
				x1<=0;
				y1<=0;
				dx<=0;
				dy<=0;
				err<=0;
				e2<=0;
				sx<=0;
				sy<=0;
				counter<=50000000;
				state<=S0;
				
			elsif (rising_edge(clock_50)) then
				case state is
--------------------------------------------------------------------------------------------------				 
				 when S0 =>
				  	
					x0<=0;
					y0<=itr*8;
					x1<=159;
					y1<=120-(itr*8);
					c<=itr mod 8;
					counter<=50000000;
					plot<='0';
					state<= S1;
					
-------------------------------------------------------------------------------------------------				
				 when S1 =>
					
					dx<=abs(x1-x0);
					dy<=abs(y1-y0);
					
					if(x0<x1)then
						sx<=1;
					else
						sx<=-1;
					end if;
					
					if(y0<y1)then
						sy<=1;
					else
						sy<=-1;
					end if;
					
					state<=S2;
-------------------------------------------------------------------------------------------------				
				when S2 =>
				
					err<=dx-dy;
					
					state<=S3;
-------------------------------------------------------------------------------------------------				
				when S3 =>
				
					x<=std_logic_vector(to_unsigned(x0,8));
					y<=std_logic_vector(to_unsigned(y0,7));
					
					if(c = 0) then
						colour<="000";
					elsif(c = 1) then
						colour<="001";
					elsif(c = 2) then
						colour<="011";
					elsif(c = 3) then
						colour<="010";
					elsif(c = 4) then
						colour<="110";
					elsif(c = 5) then
						colour<="111";
					elsif(c = 6) then
						colour<="101";
					elsif(c = 7) then
						colour<="100";
					end if;
					
					plot<='1';
					
					if(x0=x1 and y0=y1) then
						itr<=itr+1;
						
						if(itr>14)then
							itr<=1;
							state<= STATE_WAIT;
						else
						   state<=STATE_WAIT;
							--state <= s0;
						end if;
					else
						e2<=err*2;
						state<=S4;
					end if;
-------------------------------------------------------------------------------------------------				
				when S4 =>
					plot<='0';
					if(e2>-dy) then
						err<=err-dy;
						x0<=x0+sx;
					end if;
					state<=S5;
-------------------------------------------------------------------------------------------------				
				when S5 =>
					if(e2<dx) then
						err<=err+dx;
						y0<=y0+sy;
					end if;
					state<=S3;
-------------------------------------------------------------------------------------------------				
				when STATE_WAIT =>
					plot<='0';
					if (counter/= 0) then
						counter<=counter-1;
						state<=STATE_WAIT;
					else
						xtemp <= 0;
						ytemp <= 0;
						state<= STATE_ERASE_1;
					end if;
---------------------------------------------------------------------------------------------------				
				when STATE_ERASE_1 =>
					x<=std_logic_vector(to_unsigned(xTemp,8));
					y<=std_logic_vector(to_unsigned(yTemp,7));
					colour<="000";
					plot<='1';
					
					
					if (xTemp<160) then
						xTemp<=xTemp+1;
						state<=STATE_ERASE_1;
					else 
						yTemp<=yTemp+1;
						xTemp<=0;
						state<=STATE_ERASE_2;
					end if;
--					
--					
---------------------------------------------------------------------------------------------------				
				WHEN STATE_ERASE_2 =>
						
					if(yTemp>119)then
						plot<='0';
						state<=S0;
					else
						state<=STATE_ERASE_1;
					end if;
					
					
-------------------------------------------------------------------------------------------------				
			end case;
		end if;
	end process;

u2 : vga_adapter
	generic map(RESOLUTION => "160x120") 
		port map(resetn=>KEY(3),
					clock=>CLOCK_50,
					colour=>colour,
					x=>x,
					y=>y,
					plot=>plot,
					VGA_R=>VGA_R,
					VGA_G=>VGA_G,
					VGA_B=>VGA_B,
					VGA_HS=>VGA_HS,
					VGA_VS=>VGA_VS,
					VGA_BLANK=>VGA_BLANK,
					VGA_SYNC=>VGA_SYNC,
					VGA_CLK=>VGA_CLK);
					
		
end;


