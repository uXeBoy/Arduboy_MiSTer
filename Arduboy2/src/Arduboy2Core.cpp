/**
 * @file Arduboy2Core.cpp
 * \brief
 * The Arduboy2Core class for Arduboy hardware initilization and control.
 */

#include "Arduboy2Core.h"

Arduboy2Core::Arduboy2Core() { }

void Arduboy2Core::boot()
{
  bootPins();
}

// Pins are set to the proper modes and levels for the specific hardware.
// This routine must be modified if any pins are moved to a different port
void Arduboy2Core::bootPins()
{
}

uint8_t Arduboy2Core::width() { return WIDTH; }

uint8_t Arduboy2Core::height() { return HEIGHT; }

/* Drawing */

volatile uint32_t *simple_out = (uint32_t *)0xFFFFFF10;

void Arduboy2Core::paintScreen(uint8_t image[], bool clear)
{
  *simple_out |= 0x00020000; // dc HIGH

  for (uint16_t i = 0; i < 1024; i++) // 1,024 bytes
  {
    for (uint8_t r = 0; r < 8; r++) // eight bits
    {
      uint8_t bitMask = (1<<r);

      if (image[i] & bitMask) *simple_out |=  (1<<(r+8));
      else                    *simple_out &= ~(1<<(r+8));
    }
    if (clear) image[i] = 0;
    *simple_out &= ~(0x00010000); // clk LOW
    *simple_out |=   0x00010000;  // clk HIGH
  }

  // 'VSYNC'
  *simple_out &= ~(0x00030000); // clk LOW + dc LOW
  *simple_out |=   0x00010000;  // clk HIGH
}

void Arduboy2Core::blank()
{
  *simple_out |=   0x00020000;  // dc HIGH
  *simple_out &= ~(0x0000FF00); // data LOW

  for (uint16_t i = 0; i < 1024; i++) // 1,024 bytes
  {
    *simple_out &= ~(0x00010000); // clk LOW
    *simple_out |=   0x00010000;  // clk HIGH
  }

  // 'VSYNC'
  *simple_out &= ~(0x00030000); // clk LOW + dc LOW
  *simple_out |=   0x00010000;  // clk HIGH
}

// turn all display pixels on, ignoring buffer contents
// or set to normal buffer display
void Arduboy2Core::allPixelsOn(bool on)
{
  if (on)
  {
    *simple_out |= 0x0002FF00; // dc HIGH + data HIGH

    for (uint16_t i = 0; i < 1024; i++) // 1,024 bytes
    {
      *simple_out &= ~(0x00010000); // clk LOW
      *simple_out |=   0x00010000;  // clk HIGH
    }

    // 'VSYNC'
    *simple_out &= ~(0x00030000); // clk LOW + dc LOW
    *simple_out |=   0x00010000;  // clk HIGH
  }
}

/* Buttons */

volatile uint32_t *simple_in = (uint32_t *)0xFFFFFF02;

uint8_t Arduboy2Core::buttonsState()
{
  uint8_t buttons;

  buttons = ~((*simple_in >> 12) & 0xFC);

  return buttons;
}

// delay in ms with 16 bit duration
void Arduboy2Core::delayShort(uint16_t ms)
{
  delay((unsigned long) ms);
}
