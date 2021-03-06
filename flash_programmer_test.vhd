--  
-- AVR-910 Compliant In-System Programmer for Soft-IP AVR-compatible microcontrollers.
-- Simple demonstration fixture.
--
-- The MIT License (MIT)
-- 
-- Copyright (c) 2014 Kyle J. Temkin
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
-- 
--

library ieee;
use ieee.std_logic_1164.all;

entity flash_programmer_demo is
  port(
    
    --System-wide inputs.
    clk     : in std_ulogic;
    reset   : in std_ulogic := '0';
    
    --UART control interface.
    rx      : in  std_ulogic;
    tx      : out std_ulogic;

    --SPI interface (to flash memory).
    flash_sck     : buffer std_ulogic;
    flash_miso    : in  std_ulogic;
    flash_mosi    : buffer std_ulogic;
    flash_cs      : buffer std_ulogic;

    --DEBUG only
    mirror_sck      : out std_ulogic;
    mirror_miso     : out std_ulogic;
    mirror_mosi     : out std_ulogic;
    mirror_cs       : out std_ulogic;
    transact_enable : out std_ulogic;
    busy            : out std_ulogic


  );
end flash_programmer_demo;

architecture structural of flash_programmer_demo is

    --Flash memory control I/O.
    signal erase, write_to_flash          : std_ulogic;
    signal address                        : std_ulogic_vector(15 downto 0);
    signal data_from_flash                : std_ulogic_vector(15 downto 0);
    signal data_to_flash                  : std_ulogic_vector(15 downto 0);

    --CPU control signals.
    signal in_programming_mode            :  std_ulogic := '0';


    signal power_on_reset                 : std_ulogic := '1';

begin

  PROGRAMMER:
  entity work.avr_flash_programmer
    generic map(
      --The frequency of the Clk signal.
      clock_frequency => 32000000,

      --The baud rate to transmit at; defaults to 19200 in most programmers.
      baud_rate => 19200
    )
    port map(

      --Pass in the global control signals.
      clk   => clk,

      --Pass the serial signals through directly. 
      rx => rx,
      tx => tx,

      --Flash control signals.
      erase           => erase,
      address         => address,
      write_to_flash  => write_to_flash,
      data_to_flash   => data_to_flash,
      data_from_flash => std_ulogic_vector(data_from_flash),

      --CPU control signals
      in_programming_mode => open
    );

  --DEBUG
  mirror_sck  <= flash_sck;
  mirror_miso <= flash_miso;
  mirror_mosi <= flash_mosi;
  mirror_cs   <= flash_cs;


  --MEMORY:
  --entity program_memory(volatile)
  --  port map(
  --    clk     => clk,
  --    enable  => '1',

  --    write   => write_to_flash,
  --    erase   => erase,

  --    --address  => std_logic_vector(address),
  --    address  => std_logic_vector(address),
  --    data_in  => std_logic_vector(data_to_flash),
  --    data_out => data_from_flash
  --  );

  MEMORY:
  entity work.spi_program_memory
  port map(

    --Global signals.
    clk     => clk,
    enable  => '1',
    reset   => '0',

    --SPI signals
    flash_sck     => flash_sck,
    flash_miso    => flash_miso,
    flash_mosi    => flash_mosi,
    flash_cs      => flash_cs,

    write         => write_to_flash,
    erase         => erase,

    address       => address,
    data_in       => data_to_flash,
    data_out      => data_from_flash,

    transact_enable => transact_enable,
    busy => busy


  );


end structural;

