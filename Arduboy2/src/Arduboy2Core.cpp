/**
 * @file Arduboy2Core.cpp
 * \brief
 * The Arduboy2Core class for Arduboy hardware initilization and control.
 */

#include "Arduboy2Core.h"

Arduboy2Core::Arduboy2Core() { }

static volatile uint32_t *simple_out = (uint32_t *)0xFFFFFF10;
static volatile uint32_t *simple_in  = (uint32_t *)0xFFFFFF00;

uint16_t Arduboy2Core::duration = 0;
bool Arduboy2Core::tonesPlaying = false;
uint16_t Arduboy2Core::toneSequence[3];
static uint16_t *tonesStart = 0;
static uint16_t *tonesIndex = 0;

void Arduboy2Core::tone(const uint16_t freq, const uint16_t dur)
{
  toneSequence[0] = freq;
  toneSequence[1] = dur;
  toneSequence[2] = TONES_END;

  tone(toneSequence);
}

void Arduboy2Core::tone(const uint16_t *tones)
{
  uint16_t freq;

  *simple_out &= ~(FULLNOTE_MASK); // reset 'fullnote' value to zero

  tonesStart = tonesIndex = (uint16_t *)tones; // set to start of sequence array

  freq = *tonesIndex++; // get tone frequency
  duration = *tonesIndex++; // get tone duration

  *simple_out |= (FULLNOTE_MASK & ((freq & 63) << 23)); // set 'fullnote' value

  tonesPlaying = true;
}

void Arduboy2Core::timer()
{
  uint16_t freq;

  if (duration == 0)
  {
    if (tonesPlaying)
    {
      freq = *tonesIndex++; // get tone frequency

      if (freq == TONES_REPEAT) // if frequency is actually a "repeat" marker
      {
        tonesIndex = tonesStart; // reset to start of sequence
        freq = *tonesIndex++; // get tone frequency
      }
      if (freq == TONES_END)
      {
        tonesPlaying = false; // if freq is actually an "end of sequence" marker
      }
      else
      {
        duration = *tonesIndex++; // get tone duration
        if (freq == NOTE_REST)
        {
          *simple_out &= ~(FULLNOTE_MASK); // mute
        }
        else
        {
          *simple_out |= (FULLNOTE_MASK & ((freq & 63) << 23)); // 'fullnote'
        }
      }
    }
  }
  else if (--duration == 0)
  {
    *simple_out &= ~(FULLNOTE_MASK); // mute
  }
}

void Arduboy2Core::noTone()
{
  *simple_out &= ~(FULLNOTE_MASK); // mute
  tonesPlaying = false;
}

uint16_t Arduboy2Core::duration2 = 0;
bool Arduboy2Core::tonesPlaying2 = false;
uint16_t Arduboy2Core::toneSequence2[3];
static uint16_t *tonesStart2 = 0;
static uint16_t *tonesIndex2 = 0;

void Arduboy2Core::tone2(const uint16_t freq, const uint16_t dur)
{
  toneSequence2[0] = freq;
  toneSequence2[1] = dur;
  toneSequence2[2] = TONES_END;

  tone2(toneSequence2);
}

void Arduboy2Core::tone2(const uint16_t *tones)
{
  uint16_t freq;

  tonesStart2 = tonesIndex2 = (uint16_t *)tones; // set to start of sequence array

  freq = *tonesIndex2++; // get tone frequency
  duration2 = *tonesIndex2++; // get tone duration2

  *simple_out &= ~(DATA_MASK); // reset data to zero
  *simple_out |=  (DATA_MASK & (freq << 10)) | LATCH_MASK; // set data + latch
  *simple_out &= ~(LATCH_MASK); // latch LOW

  tonesPlaying2 = true;
}

void Arduboy2Core::timer2()
{
  uint16_t freq;

  if (duration2 == 0)
  {
    if (tonesPlaying2)
    {
      freq = *tonesIndex2++; // get tone frequency

      if (freq == TONES_REPEAT) // if frequency is actually a "repeat" marker
      {
        tonesIndex2 = tonesStart2; // reset to start of sequence
        freq = *tonesIndex2++; // get tone frequency
      }
      if (freq == TONES_END)
      {
        tonesPlaying2 = false; // if freq is actually an "end of sequence" marker
      }
      else
      {
        duration2 = *tonesIndex2++; // get tone duration2
        if (freq == NOTE_REST)
        {
          *simple_out &= ~(DATA_MASK);  // reset data to zero
          *simple_out |=   LATCH_MASK;  // latch HIGH
          *simple_out &= ~(LATCH_MASK); // latch LOW
        }
        else
        {
          *simple_out &= ~(DATA_MASK); // reset data to zero
          *simple_out |=  (DATA_MASK & (freq << 10)) | LATCH_MASK; // set data + latch
          *simple_out &= ~(LATCH_MASK); // latch LOW
        }
      }
    }
  }
  else if (--duration2 == 0)
  {
    *simple_out &= ~(DATA_MASK);  // reset data to zero
    *simple_out |=   LATCH_MASK;  // latch HIGH
    *simple_out &= ~(LATCH_MASK); // latch LOW
  }
}

void Arduboy2Core::noTone2()
{
  *simple_out &= ~(DATA_MASK);  // reset data to zero
  *simple_out |=   LATCH_MASK;  // latch HIGH
  *simple_out &= ~(LATCH_MASK); // latch LOW
  tonesPlaying2 = false;
}

void Arduboy2Core::boot()
{
  bootPins();
}

// Pins are set to the proper modes and levels for the specific hardware.
// This routine must be modified if any pins are moved to a different port
void Arduboy2Core::bootPins()
{
  *simple_out &= ~(FULLNOTE_MASK | DATA_MASK |
                   SD_WR_MASK | SD_RD_MASK); // mute, sd_wr + sd_rd LOW
  *simple_out |=   LATCH_MASK;  // latch HIGH
  *simple_out &= ~(LATCH_MASK); // latch LOW

  pinMode(LED_BUILTIN, OUTPUT); // setup LED_USER

  *simple_out |= SD_RD_MASK; // sd_rd HIGH (initialise EEPROM)
}

uint8_t Arduboy2Core::readEEPROM(uint16_t address)
{
  uint8_t value;

  *simple_out &= ~(SD_WR_MASK | SD_RD_MASK); // sd_wr + sd_rd LOW
  *simple_out |= SD_RD_MASK; // sd_rd HIGH

  *simple_out &= ~(ADDRESS_MASK); // reset address to zero
  if (address > 0) *simple_out |= (ADDRESS_MASK & (address << 1)); // set address

  while (*simple_in & SD_ACK_MASK) { } // wait if busy

  value = (*simple_in >> 7) & 0xFF;

  return value;
}

void Arduboy2Core::readEEPROM(uint16_t address, void *data_dest, size_t size)
{
  uint8_t value;

  for (size_t i = 0; i < size; i++)
  {
    value = readEEPROM((uint16_t) address + i);
    ((uint8_t *)data_dest)[i] = value;
  }
}

void Arduboy2Core::writeEEPROM(uint16_t address, uint8_t value)
{
  *simple_out &= ~(SD_WR_MASK | SD_RD_MASK); // sd_wr + sd_rd LOW

  *simple_out &= ~(ADDRESS_MASK); // reset address to zero
  if (address > 0) *simple_out |= (ADDRESS_MASK & (address << 1)); // set address

  if (value != (*simple_in >> 7) & 0xFF)
  {
    *simple_out &= ~(DATA_MASK); // reset data to zero
    if (value > 0) *simple_out |= (DATA_MASK & (value << 10)); // set data

    *simple_out |= GLUE_WR_MASK; // glue_wr HIGH
    while (*simple_in & SD_ACK_MASK) { } // wait if busy
    *simple_out |= SD_WR_MASK; // sd_wr HIGH
    *simple_out &= ~(GLUE_WR_MASK); // glue_wr LOW
  }
}

void Arduboy2Core::writeEEPROM(uint16_t address, void *data_source, size_t size)
{
  uint8_t value;

  for(size_t i = 0; i < size; i++)
  {
    value = ((uint8_t *)data_source)[i];
    writeEEPROM((uint16_t) address + i, value);
  }
}

uint8_t Arduboy2Core::width() { return WIDTH; }

uint8_t Arduboy2Core::height() { return HEIGHT; }

/* Drawing */

void Arduboy2Core::paintScreen(uint8_t image[], bool clear)
{
  *simple_out |= DC_MASK; // dc HIGH

  for (uint16_t i = 0; i < 1024; i++) // 1,024 bytes
  {
    *simple_out &= ~(DATA_MASK); // reset data to zero
    if (image[i] > 0) *simple_out |= (DATA_MASK & (image[i] << 10)); // set data

    if (clear) image[i] = 0;

    *simple_out &= ~(CLK_MASK); // clk LOW
    *simple_out |=   CLK_MASK;  // clk HIGH
  }

  // 'VSYNC'
  *simple_out &= ~(CLK_MASK | DC_MASK); // clk LOW + dc LOW
  *simple_out |=   CLK_MASK; // clk HIGH
}

void Arduboy2Core::blank()
{
  *simple_out |= DC_MASK; // dc HIGH
  *simple_out &= ~(DATA_MASK); // data LOW

  for (uint16_t i = 0; i < 1024; i++) // 1,024 bytes
  {
    *simple_out &= ~(CLK_MASK); // clk LOW
    *simple_out |=   CLK_MASK;  // clk HIGH
  }

  // 'VSYNC'
  *simple_out &= ~(CLK_MASK | DC_MASK); // clk LOW + dc LOW
  *simple_out |=   CLK_MASK; // clk HIGH
}

// invert the display or set to normal
// when inverted, a pixel set to 0 will be on
void Arduboy2Core::invert(bool inverse)
{
  //sendLCDCommand(inverse ? OLED_PIXELS_INVERTED : OLED_PIXELS_NORMAL);
  if (inverse) *simple_out |=   INVERT_MASK;  // invert HIGH
  else         *simple_out &= ~(INVERT_MASK); // invert LOW
}

// turn all display pixels on, ignoring buffer contents
// or set to normal buffer display
void Arduboy2Core::allPixelsOn(bool on)
{
  if (on)
  {
    *simple_out |= DC_MASK | DATA_MASK; // dc HIGH + data HIGH

    for (uint16_t i = 0; i < 1024; i++) // 1,024 bytes
    {
      *simple_out &= ~(CLK_MASK); // clk LOW
      *simple_out |=   CLK_MASK;  // clk HIGH
    }

    // 'VSYNC'
    *simple_out &= ~(CLK_MASK | DC_MASK); // clk LOW + dc LOW
    *simple_out |=   CLK_MASK; // clk HIGH
  }
}

/* Buttons */

uint8_t Arduboy2Core::buttonsState()
{
  uint8_t buttons;

  buttons = (*simple_in & 0x3F);

  return buttons;
}

/* RGB LED */

void Arduboy2Core::digitalWriteRGB(uint8_t red, uint8_t green, uint8_t blue)
{
  // only blue on DevKit
  (void)red;    // parameter unused
  (void)green;  // parameter unused
  digitalWrite(LED_BUILTIN, blue);
}

void Arduboy2Core::digitalWriteRGB(uint8_t color, uint8_t val)
{
  // only blue on DevKit
  if (color == BLUE_LED)
  {
    digitalWrite(LED_BUILTIN, val);
  }
}

// delay in ms with 16 bit duration
void Arduboy2Core::delayShort(uint16_t ms)
{
  delay((unsigned long) ms);
}
