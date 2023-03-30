library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity project_reti_logiche is
    port (
        i_clk: in std_logic;
        i_rst: in std_logic;
        i_start: in std_logic;
        i_w: in std_logic;
        
        o_z0: out std_logic_vector(7 downto 0);
        o_z1: out std_logic_vector(7 downto 0);
        o_z2: out std_logic_vector(7 downto 0);
        o_z3: out std_logic_vector(7 downto 0);
        o_done: out std_logic;
        
        o_mem_addr: out std_logic_vector(15 downto 0);
        i_mem_data: in std_logic_vector(7 downto 0);
        o_mem_we: out std_logic;
        o_mem_en: out std_logic
    ); 
end project_reti_logiche;

architecture arch of project_reti_logiche is
    component reg18 port (
        w, start, clk, reset, done: in std_logic;
        
        output16: out std_logic_vector (15 downto 0);
        output2: out std_logic_vector (1 downto 0)
    );
    end component;
    component reg32 port (
        memory: in std_logic_vector (7 downto 0);
        x, y: in std_logic;
        done, clk, reset: in std_logic;
        
        z0, z1, z2, z3: out std_logic_vector (7 downto 0)
    );
    end component;
    component timer port (
        start, clk, reset: in std_logic;
        
        done: out std_logic
    );
    end component;
    signal done: std_logic;
    signal output16: std_logic_vector (15 downto 0);
    signal output2: std_logic_vector (1 downto 0);
begin
    o_mem_we <= '0';
    o_mem_en <= i_start;
    o_done <= done;
    o_mem_addr <= output16;
    firstset: reg18 port map (
        w => i_w,
        start => i_start,
        clk => i_clk,
        reset => i_rst,
        done => done,
        output16 => output16,
        output2 => output2
    );
    secondset: reg32 port map (
        memory => i_mem_data,
        x => output2(0),
        y => output2(1),
        done => done,
        clk => i_clk,
        reset => i_rst,
        z0 => o_z0,
        z1 => o_z1,
        z2 => o_z2,
        z3 => o_z3
    );
    donetimer: timer port map(
        start => i_start,
        clk => i_clk,
        reset => i_rst,
        done => done
    );
end arch;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity demultiplexer1 is
    port (
        i, s: in std_logic;
        
        a, b: out std_logic
    );
end demultiplexer1;

architecture rtl of demultiplexer1 is
begin
    a <= not s and i;
    b <= s and i;
end rtl;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity demultiplexer2 is
    port (
        i : in std_logic_vector(7 downto 0);
        x, y : in std_logic;
        a, b, c, d : out std_logic_vector(7 downto 0)
    );
end demultiplexer2;

architecture rtl of demultiplexer2 is
    signal xv, yv: std_logic_vector (7 downto 0);
begin
    xv <= x & x & x & x & x & x & x & x;
    yv <= y & y & y & y & y & y & y & y;
    a <= not xv and not yv and i; 
    b <= not xv and yv and i;
    c <= xv and not yv and i;
    d <= xv and yv and i;
end rtl;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decoder is
    port (
        x, y: in std_logic;
        a, b, c, d: out std_logic
    );
end decoder;

architecture rtl of decoder is
begin
    a <= not x and not y;
    b <= not x and y;
    c <= x and not y;
    d <= x and y;
end rtl;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity latch is
    port (
        d, en, reset: in std_logic;
        
        q, qn: out std_logic
    );
end latch;

architecture rtl of latch is
    signal a, b, d1, z, zn: std_logic;
begin
    d1 <= d and not reset;
    a <= d1 and en;
    b <= not d1 and en;
    z <= b nor zn;
    zn <= a nor z;
    q <= z;
    qn <= zn;    
end rtl;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity nlatch is
    port (
        d, en, reset: in std_logic;
        
        q, qn: out std_logic
    );
end nlatch;

architecture rtl of nlatch is
    signal a, b, d1, z, zn: std_logic;
begin
    d1 <= d or reset;
    a <= d1 and en;
    b <= not d1 and en;
    z <= b nor zn;
    zn <= a nor z;
    q <= z;
    qn <= zn;    
end rtl;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity flipflop is
    port (
        d, en, reset: in std_logic;
        
        q, qn: out std_logic
    );
end flipflop;

architecture behavioral of flipflop is
    signal q_int : std_logic := '0';
begin
    process (en, reset)
    begin
        if reset = '1' then
            q_int <= '0';
        elsif en = '1' then
            q_int <= d;
        end if;
    end process;

    q <= q_int;
    qn <= not q_int;
end behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity nflipflop is
    port (
        d, en, reset: in std_logic;
        
        q, qn: out std_logic
    );
end nflipflop;

architecture behavioral of nflipflop is
    signal q_int : std_logic := '1'; 
begin
    process (en, reset)
    begin
        if reset = '1' then 
            q_int <= '1';
        elsif en = '1' then
            q_int <= d;
        end if;
    end process;

    q <= q_int;
    qn <= not q_int;
end behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg16 is
    port (
        input, en, reset: in std_logic;
        
        output: out std_logic_vector (15 downto 0)
    );
end reg16;

architecture rtl of reg16 is
    signal qs: std_logic_vector (15 downto 0);
    component flipflop is
        port (
            d, en, reset: in std_logic;
            
            q, qn: out std_logic
        );
    end component;
begin
    output <= qs;
    qs(0) <= input;
    flipflop14: flipflop port map(
        d => qs(0),
        en => en,
        reset => reset,
        q => qs(1)
    );
    flipflop13: flipflop port map(
        d => qs(1),
        en => en,
        reset => reset,
        q => qs(2)
    );
    flipflop12: flipflop port map(
        d => qs(2),
        en => en,
        reset => reset,
        q => qs(3)
    );
    flipflop11: flipflop port map(
        d => qs(3),
        en => en,
        reset => reset,
        q => qs(4)
    );
    flipflop10: flipflop port map(
        d => qs(4),
        en => en,
        reset => reset,
        q => qs(5)
    );
    flipflop9: flipflop port map(
        d => qs(5),
        en => en,
        reset => reset,
        q => qs(6)
    );
    flipflop8: flipflop port map(
        d => qs(6),
        en => en,
        reset => reset,
        q => qs(7)
    );
    flipflop7: flipflop port map(
        d => qs(7),
        en => en,
        reset => reset,
        q => qs(8)
    );
    flipflop6: flipflop port map(
        d => qs(8),
        en => en,
        reset => reset,
        q => qs(9)
    );
    flipflop5: flipflop port map(
        d => qs(9),
        en => en,
        reset => reset,
        q => qs(10)
    );
    flipflop4: flipflop port map(
        d => qs(10),
        en => en,
        reset => reset,
        q => qs(11)
    );
    flipflop3: flipflop port map(
        d => qs(11),
        en => en,
        reset => reset,
        q => qs(12)
    );
    flipflop2: flipflop port map(
        d => qs(12),
        en => en,
        reset => reset,
        q => qs(13)
    );
    flipflop1: flipflop port map(
        d => qs(13),
        en => en,
        reset => reset,
        q => qs(14)
    );
    flipflop0: flipflop port map(
        d => qs(14),
        en => en,
        reset => reset,
        q => qs(15)
    );
end rtl;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg3 is
    port (
        input, en, reset: in std_logic;
        
        output: out std_logic_vector (2 downto 0)
    );
end reg3;

architecture rtl of reg3 is
    signal qs: std_logic_vector (2 downto 0);
    component flipflop is
        port (
            d, en, reset: in std_logic;
            
            q, qn: out std_logic
        );
    end component;
    component nflipflop is
        port (
            d, en, reset: in std_logic;
            
            q, qn: out std_logic
        );
    end component;
begin
    output <= qs;
    flipflop2: nflipflop port map(
        d => input,
        en => en,
        reset => reset,
        q => qs(2)
    );
    flipflop1: flipflop port map(
        d => qs(2),
        en => en,
        reset => reset,
        q => qs(1)
    );
    flipflop0: flipflop port map(
        d => qs(1),
        en => en,
        reset => reset,
        q => qs(0)
    );
end rtl;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg18 is
    port (
        w, start, clk, reset, done: in std_logic;
        
        output16: out std_logic_vector (15 downto 0);
        output2: out std_logic_vector (1 downto 0)
    );
end reg18;

architecture rtl of reg18 is
    component reg16 port (
        input, en, reset: in std_logic;
        
        output: out std_logic_vector (15 downto 0)
    );
    end component;
    component reg3 port (
        input, en, reset: in std_logic;
        
        output: out std_logic_vector (2 downto 0)
    );
    end component;
    component demultiplexer1 port (
        i, s: in std_logic;
        
        a, b: out std_logic
    );
    end component;
    signal out16: std_logic_vector (15 downto 0);
    signal out3: std_logic_vector (2 downto 0);
    signal in16: std_logic;
    signal in3: std_logic;
    signal selection: std_logic;
    signal inputdemux: std_logic;
    signal enablereg3: std_logic;
    signal resetreg: std_logic;
begin
    selection <= out3(0);
    output16 <= out16;
    output2 <= out3(2)&out3(1);
    inputdemux <= w and start;
    enablereg3 <= (reset and clk) or (start and not selection and clk);
    resetreg <= done or reset;
    demultiplexer: demultiplexer1 port map (
        i => inputdemux,
        s => selection,
        a => in3,
        b => in16
    );
    bigreg: reg16 port map (
        input => in16,
        en => clk,
        reset => resetreg,
        output => out16
    );
    smallreg: reg3 port map (
        input => in3,
        en => enablereg3,
        reset => resetreg,
        output => out3
    );
end rtl;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg8 is
    port (
        input: in std_logic_vector (7 downto 0);
        en, reset: in std_logic;
        
        output: out std_logic_vector (7 downto 0)
    );
end reg8;

architecture rtl of reg8 is
    component latch port (
        d, en, reset: in std_logic;
        
        q, qn: out std_logic
    );
    end component;
begin
    latch7: latch port map (
        d => input(7),
        en => en,
        reset => reset,
        q => output(7)
    );
    latch6: latch port map (
        d => input(6),
        en => en,
        reset => reset,
        q => output(6)
    );
    latch5: latch port map (
        d => input(5),
        en => en,
        reset => reset,
        q => output(5)
    );
    latch4: latch port map (
        d => input(4),
        en => en,
        reset => reset,
        q => output(4)
    );
    latch3: latch port map (
        d => input(3),
        en => en,
        reset => reset,
        q => output(3)
    );
    latch2: latch port map (
        d => input(2),
        en => en,
        reset => reset,
        q => output(2)
    );
    latch1: latch port map (
        d => input(1),
        en => en,
        reset => reset,
        q => output(1)
    );
    latch0: latch port map (
        d => input(0),
        en => en,
        reset => reset,
        q => output(0)
    );
end rtl;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity timer is
    port (
        start, clk, reset: in std_logic;
        
        done: out std_logic
    );
end timer;

architecture rtl of timer is
    component flipflop port (
        d, en, reset: in std_logic;
        
        q, qn: out std_logic
    );
    end component;
    signal temp: std_logic;
begin
    done <= temp and not start;
    flipflop0: flipflop port map (
        d => start,
        en => clk,
        reset => reset,
        q => temp
    );
end rtl;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg32 is
    port (
        memory: in std_logic_vector (7 downto 0);
        x, y: in std_logic;
        done, clk, reset: in std_logic;
        
        z0, z1, z2, z3: out std_logic_vector (7 downto 0)
    );
end reg32;

architecture rtl of reg32 is
    component demultiplexer2 port (
        i : in std_logic_vector(7 downto 0);
        x, y : in std_logic;
        a, b, c, d : out std_logic_vector(7 downto 0)
    );
    end component;
    component decoder port (
        x, y: in std_logic;
        a, b, c, d: out std_logic
    );
    end component;
    component reg8 port (
        input: in std_logic_vector (7 downto 0);
        en, reset: in std_logic;
        
        output: out std_logic_vector (7 downto 0)
    );
    end component;
    signal demuxa: std_logic_vector (7 downto 0);
    signal demuxb: std_logic_vector (7 downto 0);
    signal demuxc: std_logic_vector (7 downto 0);
    signal demuxd: std_logic_vector (7 downto 0);
    signal enablea: std_logic;
    signal enableb: std_logic;
    signal enablec: std_logic;
    signal enabled: std_logic;
    signal deca: std_logic;
    signal decb: std_logic;
    signal decc: std_logic;
    signal decd: std_logic;
    signal out1: std_logic_vector (7 downto 0);
    signal out2: std_logic_vector (7 downto 0);
    signal out3: std_logic_vector (7 downto 0);
    signal out4: std_logic_vector (7 downto 0);
    signal en1: std_logic;
    signal en2: std_logic;
    signal en3: std_logic;
    signal en4: std_logic;
    signal superdone: std_logic_vector (7 downto 0);
begin
    en1 <= clk and (reset or (done and deca));
    en2 <= clk and (reset or (done and decb));
    en3 <= clk and (reset or (done and decc));
    en4 <= clk and (reset or (done and decd));
    superdone <= done & done & done & done & done & done & done & done;
    z0 <= out1 and superdone;
    z1 <= out2 and superdone;
    z2 <= out3 and superdone;
    z3 <= out4 and superdone;
    demux: demultiplexer2 port map (
        i => memory,
        x => x,
        y => y,
        a => demuxa,
        b => demuxb,
        c => demuxc,
        d => demuxd
    );
    dec: decoder port map (
        x => x,
        y => y,
        a => deca,
        b => decb,
        c => decc,
        d => decd
    );
    r1: reg8 port map (
        input => demuxa,
        en => en1,
        reset => reset,
        output => out1
    );
    r2: reg8 port map (
        input => demuxb,
        en => en2,
        reset => reset,
        output => out2
    );
    r3: reg8 port map (
        input => demuxc,
        en => en3,
        reset => reset,
        output => out3
    );
    r4: reg8 port map (
        input => demuxd,
        en => en4,
        reset => reset,
        output => out4
    );
end rtl;