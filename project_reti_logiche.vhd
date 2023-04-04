library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity project_reti_logiche is
    port(
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
    component init port(
        reset, clock: in std_logic;
        start, finish: in std_logic;
        input: in std_logic;
        outputA: out std_logic_vector (15 downto 0);
        outputB: out std_logic_vector (1 downto 0)
    );
    end component;
    component demux1 port(
        input: in std_logic_vector (7 downto 0);
        selection: in std_logic_vector (1 downto 0);
        outputA, outputB, outputC, outputD: out std_logic_vector (7 downto 0)
    );
    end component;
    component decoder port(
        input: in std_logic_vector (1 downto 0);
        outputA, outputB, outputC, outputD: out std_logic
    );
    end component;
    component close port(
        reset, clock: in std_logic;
        done, done2, dec: in std_logic;
        dem1, memory: in std_logic_vector (7 downto 0);
        output: out std_logic_vector (7 downto 0)
    );
    end component;
    component doneMachine port(
        reset, clock: in std_logic;
        input: in std_logic;
        done1, done2, done: out std_logic;
        finish: out std_logic
    );
    end component;
    signal done, done1, done2, finish: std_logic;
    signal inputInit: std_logic;
    signal inputDecoder: std_logic_vector (1 downto 0);
    signal inputClose0, inputClose1, inputClose2, inputClose3: std_logic_vector (7 downto 0);
    signal decClose0, decClose1, decClose2, decClose3: std_logic;
begin
    o_mem_we <= '0';
    o_mem_en <= i_start;
    o_done <= done;
    inputInit <= i_w and i_start;
    doneMach: doneMachine port map(
        reset => i_rst,
        clock => i_clk,
        input => i_start,
        done1 => done1,
        done2 => done2,
        done => done,
        finish => finish
    );
    initial: init port map(
        reset => i_rst,
        clock => i_clk,
        start => i_start,
        finish => finish,
        input => inputInit,
        outputA => o_mem_addr,
        outputB => inputDecoder
    );
    demultiplexer1: demux1 port map(
        input => i_mem_data,
        selection => inputDecoder,
        outputA => inputClose0,
        outputB => inputClose1,
        outputC => inputClose2,
        outputD => inputClose3
    );
    decoder1: decoder port map(
        input => inputDecoder,
        outputA => decClose0,
        outputB => decClose1,
        outputC => decClose2,
        outputD => decClose3
    );
    close0: close port map(
        reset => i_rst,
        clock => i_clk,
        done => done,
        done2 => done2,
        dec => decClose0,
        dem1 => inputClose0,
        memory => i_mem_data,
        output => o_z0
    );
    close1: close port map(
        reset => i_rst,
        clock => i_clk,
        done => done,
        done2 => done2,
        dec => decClose1,
        dem1 => inputClose1,
        memory => i_mem_data,
        output => o_z1
    );
    close2: close port map(
        reset => i_rst,
        clock => i_clk,
        done => done,
        done2 => done2,
        dec => decClose2,
        dem1 => inputClose2,
        memory => i_mem_data,
        output => o_z2
    );
    close3: close port map(
        reset => i_rst,
        clock => i_clk,
        done => done,
        done2 => done2,
        dec => decClose3,
        dem1 => inputClose3,
        memory => i_mem_data,
        output => o_z3
    );
end arch;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity doneMachine is 
    port(
        reset, clock: in std_logic;
        input: in std_logic;
        done1, done2, done: out std_logic;
        finish: out std_logic
    );
end doneMachine;
architecture arch of doneMachine is
    component flipflop port(
        d: in std_logic;
        reset, clock: in std_logic;
        q: out std_logic
    );
    end component;
    signal done1sign, done2sign, preDone1, preDone2: std_logic;
    signal notClk: std_logic;
begin
    notClk <= not clock;
    done1 <= done1sign;
    done2 <= done2sign;
    done <= done1sign or done2sign;
    finish <= done2sign;
    done1sign <= preDone1 and not input;
    done2sign <= preDone2 and not preDone1;
    FF1: flipflop port map(
        d => input,
        reset => reset,
        clock => clock,
        q => preDone1
    );
    FF2: flipflop port map(
        d => preDone1,
        reset => reset,
        clock => notClk,
        q => preDone2
    );
end arch;
    

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity reg15 is 
    port(
        reset, enable, clock: in std_logic;
        input: in std_logic;
        output: out std_logic_vector (14 downto 0)
    );
end reg15;
architecture arch of reg15 is
    signal value : std_logic_vector (14 downto 0);
begin
    process(clock, reset)
    begin
        if reset = '1' then
            value <= "000000000000000";
        elsif rising_edge(clock) and enable = '1' then
            value (14 downto 1) <= value (13 downto 0);
            value(0) <= input;
        end if;
    end process;
    output <= value;
end arch;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity reg3 is 
    port(
        reset, enable, clock: in std_logic;
        input: in std_logic;
        output: out std_logic_vector (2 downto 0)
    );
end reg3;
architecture arch of reg3 is
    signal value : std_logic_vector (2 downto 0);
begin
    process(clock, reset)
    begin
        if reset = '1' then
            value <= "100";
        elsif rising_edge(clock) and enable = '1' then
            value <= input & value (2 downto 1);
        end if;
    end process;
    output <= value;
end arch;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity reg8 is 
    port(
        reset, enable, clock: in std_logic;
        input: in std_logic_vector (7 downto 0);
        output: out std_logic_vector (7 downto 0)
    );
end reg8;
architecture arch of reg8 is
    signal value: std_logic_vector(7 downto 0);
begin
    process(clock)
    begin
        if rising_edge(clock) then
            if reset = '1' then
                value <= "00000000";
            elsif enable = '1' then
                value <= input;
            end if;
        end if;
    end process;
    output <= value;
end arch;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity mux1 is 
    port(
        inputA, inputB: in std_logic_vector (7 downto 0);
        selection: in std_logic;
        output: out std_logic_vector (7 downto 0)
    );
end mux1;
architecture arch of mux1 is
begin
    process(selection, inputA, inputB)
    begin
        if selection = '0' then
            output <= inputA;
        else
            output <= inputB;
        end if;
    end process;
end arch;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity mux2 is 
    port(
        inputA, inputB: in std_logic_vector (1 downto 0);
        selection: in std_logic;
        output: out std_logic_vector (1 downto 0)
    );
end mux2;
architecture arch of mux2 is
begin
    process(selection, inputA, inputB)
    begin
        if selection = '0' then
            output <= inputA;
        else
            output <= inputB;
        end if;
    end process;
end arch;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity demux1 is 
    port(
        input: in std_logic_vector (7 downto 0);
        selection: in std_logic_vector (1 downto 0);
        outputA, outputB, outputC, outputD: out std_logic_vector (7 downto 0)
    );
end demux1;
architecture arch of demux1 is
begin
    process(input, selection)
    begin
        case selection is
            when "00" =>
                outputA <= input;
                outputB <= (others => '0');
                outputC <= (others => '0');
                outputD <= (others => '0');
            when "01" =>
                outputA <= (others => '0');
                outputB <= input;
                outputC <= (others => '0');
                outputD <= (others => '0');
            when "10" =>
                outputA <= (others => '0');
                outputB <= (others => '0');
                outputC <= input;
                outputD <= (others => '0');
            when others =>
                outputA <= (others => '0');
                outputB <= (others => '0');
                outputC <= (others => '0');
                outputD <= input;
        end case;
    end process;
end arch;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity demux2 is 
    port(
        input: in std_logic;
        selection: in std_logic;
        outputA, outputB: out std_logic
    );
end demux2;
architecture arch of demux2 is
begin
    process(input, selection)
    begin
        if selection = '0' then
            outputA <= input;
            outputB <= '0';
        else
            outputA <= '0';
            outputB <= input;
        end if;
    end process;
end arch;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity decoder is 
    port(
        input: in std_logic_vector (1 downto 0);
        outputA, outputB, outputC, outputD: out std_logic
    );
end decoder;
architecture arch of decoder is
begin
    process(input)
    begin
        case input is
            when "00" =>
                outputA <= '1';
                outputB <= '0';
                outputC <= '0';
                outputD <= '0';
            when "01" =>
                outputA <= '0';
                outputB <= '1';
                outputC <= '0';
                outputD <= '0';
            when "10" =>
                outputA <= '0';
                outputB <= '0';
                outputC <= '1';
                outputD <= '0';
            when others =>
                outputA <= '0';
                outputB <= '0';
                outputC <= '0';
                outputD <= '1';
        end case;
    end process;
end arch;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity sel is 
    port(
        reset, clock: in std_logic;
        start, finish: in std_logic;
        input: in std_logic;
        selection: out std_logic;
        output: out std_logic_vector (1 downto 0)
    );
end sel;
architecture arch of sel is
    component reg3 port(
        reset, enable, clock: in std_logic;
        input: in std_logic;
        output: out std_logic_vector (2 downto 0)
    );
    end component;
    component mux2 port(
        inputA, inputB: in std_logic_vector (1 downto 0);
        selection: in std_logic;
        output: out std_logic_vector (1 downto 0)
    );
    end component;
    signal MSBreg3: std_logic;
    signal resetReg3, enableReg3: std_logic;
    signal outputReg3: std_logic_vector (2 downto 0);
    signal inputAmux2, inputBmux2: std_logic_vector (1 downto 0);
begin
    resetReg3 <= finish or reset;
    enableReg3 <= reset or (start and not MSBreg3);
    MSBreg3 <= outputReg3(0);
    inputAmux2 <= outputReg3(2) & input;
    inputBmux2 <= outputReg3(1) & outputReg3(2);
    selection <= MSBreg3;
    register3: reg3 port map(
        reset => resetReg3,
        enable => enableReg3,
        clock => clock,
        input => input,
        output => outputReg3
    );
    multiplexer2: mux2 port map(
        inputA => inputAmux2,
        inputB => inputBmux2,
        selection => MSBreg3,
        output => output
    );
end arch;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity init is 
    port(
        reset, clock: in std_logic;
        start, finish: in std_logic;
        input: in std_logic;
        outputA: out std_logic_vector (15 downto 0);
        outputB: out std_logic_vector (1 downto 0)
    );
end init;
architecture arch of init is
    component reg15 port(
        reset, enable, clock: in std_logic;
        input: in std_logic;
        output: out std_logic_vector (14 downto 0)
    );
    end component;
    component sel port(
        reset, clock: in std_logic;
        start, finish: in std_logic;
        input: in std_logic;
        selection: out std_logic;
        output: out std_logic_vector (1 downto 0)
    );
    end component;
    component demux2 port(
        input: in std_logic;
        selection: in std_logic;
        outputA, outputB: out std_logic
    );
    end component;
    signal resetReg15: std_logic;
    signal outputReg15: std_logic_vector (14 downto 0);
    signal outputADEMUX2, outputBDEMUX2: std_logic;
    signal passingSelect: std_logic;
begin
    resetReg15 <= finish or reset;
    outputA <= outputReg15 & outputBDEMUX2;
    register15: reg15 port map(
        reset => resetReg15,
        enable => '1',
        clock => clock,
        input => outputBDEMUX2,
        output => outputReg15
    );
    selector: sel port map(
        reset => reset,
        clock => clock,
        start => start,
        finish => finish,
        input => outputADEMUX2,
        selection => passingSelect,
        output => outputB
    );
    demultiplexer2: demux2 port map(
        input => input,
        selection => passingSelect,
        outputA => outputADEMUX2,
        outputB => outputBDEMUX2
    );
end arch;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity close is 
    port(
        reset, clock: in std_logic;
        done, done2, dec: in std_logic;
        dem1, memory: in std_logic_vector (7 downto 0);
        output: out std_logic_vector (7 downto 0)
    );
end close;
architecture arch of close is
    component reg8 port(
        reset, enable, clock: in std_logic;
        input: in std_logic_vector (7 downto 0);
        output: out std_logic_vector (7 downto 0)
    );
    end component;
    component mux1 port(
        inputA, inputB: in std_logic_vector (7 downto 0);
        selection: in std_logic;
        output: out std_logic_vector (7 downto 0)
    );
    end component;
    signal enableReg8, selectMux: std_logic;
    signal superdone: std_logic_vector (7 downto 0);
    signal inputBmux1, outputMUX1: std_logic_vector (7 downto 0);
begin
    enableReg8 <= (done and dec) or reset;
    superdone <= done & done & done & done & done & done & done & done;
    output <= superdone and outputMUX1;
    selectMux <= dec and not done2;
    register8: reg8 port map(
        reset => reset,
        enable => enableReg8,
        clock => clock,
        input => dem1,
        output => inputBmux1
    );
    multiplexer1: mux1 port map(
        inputA => inputBmux1,
        inputB => memory,
        selection => selectMux,
        output => outputMUX1
    );
end arch;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity flipflop is
    port(
        d: in std_logic;
        reset, clock: in std_logic;
        q: out std_logic
    );
end flipflop;
architecture arch of flipflop is
begin
    process (clock, reset)
    begin
        if reset = '1' then
            q <= '0';
        elsif rising_edge(clock) then
            q <= d;
        end if;
    end process;
end arch;
