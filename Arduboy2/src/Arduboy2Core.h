/**
 * @file Arduboy2Core.h
 * \brief
 * The Arduboy2Core class for Arduboy hardware initilization and control.
 */

#ifndef ARDUBOY2_CORE_H
#define ARDUBOY2_CORE_H

#include <Arduino.h>

// main hardware compile flags

#if !defined(ARDUBOY_10) && !defined(AB_DEVKIT)
/* defaults to Arduboy Release 1.0 if not using a boards.txt file
 *
 * we default to Arduboy Release 1.0 if a compile flag has not been
 * passed to us from a boards.txt file
 *
 * if you wish to compile for the devkit without using a boards.txt
 * file simply comment out the ARDUBOY_10 define and uncomment
 * the AB_DEVKIT define like this:
 *
 *     // #define ARDUBOY_10
 *     #define AB_DEVKIT
 */
#define ARDUBOY_10   //< compile for the production Arduboy v1.0
// #define AB_DEVKIT    //< compile for the official dev kit
#endif

#define RGB_ON HIGH  /**< For digitially setting an RGB LED on using digitalWriteRGB() */
#define RGB_OFF LOW  /**< For digitially setting an RGB LED off using digitalWriteRGB() */
#define BLUE_LED 13  /**< The pin number for the blue color in the RGB LED. */

// bit values for button states
// these are determined by the buttonsState() function
#define RIGHT_BUTTON 1 /**< The Right button value for functions requiring a bitmask */
#define LEFT_BUTTON  2 /**< The Left button value for functions requiring a bitmask */
#define DOWN_BUTTON  4 /**< The Down button value for functions requiring a bitmask */
#define UP_BUTTON    8 /**< The Up button value for functions requiring a bitmask */
#define A_BUTTON    16 /**< The A button value for functions requiring a bitmask */
#define B_BUTTON    32 /**< The B button value for functions requiring a bitmask */

#define WIDTH 128 /**< The width of the display in pixels */
#define HEIGHT 64 /**< The height of the display in pixels */

#define SD_ACK_MASK    0x00000040
#define SD_RD_MASK     0x80000000
#define SD_WR_MASK     0x40000000
#define GLUE_WR_MASK   0x20000000
#define FULLNOTE_MASK  0x1F800000
#define DC_MASK        0x00400000
#define CLK_MASK       0x00200000
#define INVERT_MASK    0x00100000
#define LATCH_MASK     0x00080000
#define DATA_MASK      0x0003FC00
#define ADDRESS_MASK   0x000003FE

#define NOTE_REST  0
#define NOTE_A2    1
#define NOTE_AS2   2
#define NOTE_B2    3
#define NOTE_C3    4
#define NOTE_CS3   5
#define NOTE_D3    6
#define NOTE_DS3   7
#define NOTE_E3    8
#define NOTE_F3    9
#define NOTE_FS3  10
#define NOTE_G3   11
#define NOTE_GS3  12
#define NOTE_A3   13
#define NOTE_AS3  14
#define NOTE_B3   15
#define NOTE_C4   16
#define NOTE_CS4  17
#define NOTE_D4   18
#define NOTE_DS4  19
#define NOTE_E4   20
#define NOTE_F4   21
#define NOTE_FS4  22
#define NOTE_G4   23
#define NOTE_GS4  24
#define NOTE_A4   25
#define NOTE_AS4  26
#define NOTE_B4   27
#define NOTE_C5   28
#define NOTE_CS5  29
#define NOTE_D5   30
#define NOTE_DS5  31
#define NOTE_E5   32
#define NOTE_F5   33
#define NOTE_FS5  34
#define NOTE_G5   35
#define NOTE_GS5  36
#define NOTE_A5   37
#define NOTE_AS5  38
#define NOTE_B5   39
#define NOTE_C6   40
#define NOTE_CS6  41
#define NOTE_D6   42
#define NOTE_DS6  43
#define NOTE_E6   44
#define NOTE_F6   45
#define NOTE_FS6  46
#define NOTE_G6   47
#define NOTE_GS6  48
#define NOTE_A6   49
#define NOTE_AS6  50
#define NOTE_B6   51
#define NOTE_C7   52
#define NOTE_CS7  53
#define NOTE_D7   54
#define NOTE_DS7  55
#define NOTE_E7   56
#define NOTE_F7   57
#define NOTE_FS7  58
#define NOTE_G7   59
#define NOTE_GS7  60
#define NOTE_A7   61
#define NOTE_AS7  62
#define NOTE_B7   63
#define TONES_END 64 // Frequency value for sequence termination. (No duration follows)
#define TONES_REPEAT 128 // Frequency value for sequence repeat. (No duration follows)

/** \brief
 * Lower level functions generally dealing directly with the hardware.
 *
 * \details
 * This class is inherited by Arduboy2Base and thus also Arduboy2, so wouldn't
 * normally be used directly by a sketch.
 *
 * \note
 * A friend class named _Arduboy2Ex_ is declared by this class. The intention
 * is to allow a sketch to create an _Arduboy2Ex_ class which would have access
 * to the private and protected members of the Arduboy2Core class. It is hoped
 * that this may eliminate the need to create an entire local copy of the
 * library, in order to extend the functionality, in most circumstances.
 */
class Arduboy2Core
{
  friend class Arduboy2Ex;

  public:
    Arduboy2Core();

    /** \brief
     * Get the width of the display in pixels.
     *
     * \return The width of the display in pixels.
     *
     * \note
     * In most cases, the defined value `WIDTH` would be better to use instead
     * of this function.
     */
    uint8_t static width();

    /** \brief
     * Get the height of the display in pixels.
     *
     * \return The height of the display in pixels.
     *
     * \note
     * In most cases, the defined value `HEIGHT` would be better to use instead
     * of this function.
     */
    uint8_t static height();

    /** \brief
     * Get the current state of all buttons as a bitmask.
     *
     * \return A bitmask of the state of all the buttons.
     *
     * \details
     * The returned mask contains a bit for each button. For any pressed button,
     * its bit will be 1. For released buttons their associated bits will be 0.
     *
     * The following defined mask values should be used for the buttons:
     *
     * LEFT_BUTTON, RIGHT_BUTTON, UP_BUTTON, DOWN_BUTTON, A_BUTTON, B_BUTTON
     */
    uint8_t static buttonsState();

    /** \brief
     * Paints an entire image directly to the display from an array in RAM.
     *
     * \param image A byte array in RAM representing the entire contents of
     * the display.
     * \param clear If `true` the array in RAM will be cleared to zeros upon
     * return from this function. If `false` the RAM buffer will remain
     * unchanged. (optional; defaults to `false`)
     *
     * \details
     * The contents of the specified array in RAM is written to the display.
     * Each byte in the array represents a vertical column of 8 pixels with
     * the least significant bit at the top. The bytes are written starting
     * at the top left, progressing horizontally and wrapping at the end of
     * each row, to the bottom right. The size of the array must exactly
     * match the number of pixels in the entire display.
     *
     * If parameter `clear` is set to `true` the RAM array will be cleared to
     * zeros after its contents are written to the display.
     *
     * \see paint8Pixels()
     */
    void static paintScreen(uint8_t image[], bool clear = false);

    /** \brief
     * Blank the display screen by setting all pixels off.
     *
     * \details
     * All pixels on the screen will be written with a value of 0 to turn
     * them off.
     */
    void static blank();

    /** \brief
     * Invert the entire display or set it back to normal.
     *
     * \param inverse `true` will invert the display. `false` will set the
     * display to no-inverted.
     *
     * \details
     * Calling this function with a value of `true` will set the display to
     * inverted mode. A pixel with a value of 0 will be on and a pixel set to 1
     * will be off.
     *
     * Once in inverted mode, the display will remain this way
     * until it is set back to non-inverted mode by calling this function with
     * `false`.
     */
    void static invert(bool inverse);

    /** \brief
     * Turn all display pixels on or display the buffer contents.
     *
     * \param on `true` turns all pixels on. `false` displays the contents
     * of the hardware display buffer.
     *
     * \details
     * Calling this function with a value of `true` will override the contents
     * of the hardware display buffer and turn all pixels on. The contents of
     * the hardware buffer will remain unchanged.
     *
     * Calling this function with a value of `false` will set the normal state
     * of displaying the contents of the hardware display buffer.
     *
     * \note
     * All pixels will be lit even if the display is in inverted mode.
     *
     * \see invert()
     */
    void static allPixelsOn(bool on);

    /** \brief
     * Set the RGB LEDs digitally, to either fully on or fully off.
     *
     * \param red,green,blue Use value RGB_ON or RGB_OFF to set each LED.
     *
     * \details
     * The RGB LED is actually individual red, green and blue LEDs placed
     * very close together in a single package. This 3 parameter version of the
     * function will set each LED either on or off, to set the RGB LED to
     * 7 different colors at their highest brightness or turn it off.
     *
     * The colors are as follows:
     *
     *     RED LED   GREEN_LED   BLUE_LED   COLOR
     *     -------   ---------  --------    -----
     *     RGB_OFF    RGB_OFF    RGB_OFF    OFF
     *     RGB_OFF    RGB_OFF    RGB_ON     Blue
     *     RGB_OFF    RGB_ON     RGB_OFF    Green
     *     RGB_OFF    RGB_ON     RGB_ON     Cyan
     *     RGB_ON     RGB_OFF    RGB_OFF    Red
     *     RGB_ON     RGB_OFF    RGB_ON     Magenta
     *     RGB_ON     RGB_ON     RGB_OFF    Yellow
     *     RGB_ON     RGB_ON     RGB_ON     White
     *
     * \note
     * \parblock
     * Using the RGB LED in analog mode will prevent digital control of the
     * LED. To restore the ability to control the LED digitally, use the
     * `freeRGBled()` function.
     * \endparblock
     *
     * \note
     * \parblock
     * Many of the Kickstarter Arduboys were accidentally shipped with the
     * RGB LED installed incorrectly. For these units, the green LED cannot be
     * lit. As long as the green led is set to off, turning on the red LED will
     * actually light the blue LED and turning on the blue LED will actually
     * light the red LED. If the green LED is turned on, none of the LEDs
     * will light.
     * \endparblock
     *
     * \see digitalWriteRGB(uint8_t, uint8_t) setRGBled() freeRGBled()
     */
    void static digitalWriteRGB(uint8_t red, uint8_t green, uint8_t blue);

    /** \brief
     * Set one of the RGB LEDs digitally, to either fully on or fully off.
     *
     * \param color The name of the LED to set. The value given should be one
     * of RED_LED, GREEN_LED or BLUE_LED.
     *
     * \param val Indicates whether to turn the specified LED on or off.
     * The value given should be RGB_ON or RGB_OFF.
     *
     * \details
     * This 2 parameter version of the function will set a single LED within
     * the RGB LED either fully on or fully off. See the description of the
     * 3 parameter version of this function for more details on the RGB LED.
     *
     * \see digitalWriteRGB(uint8_t, uint8_t, uint8_t) setRGBled() freeRGBled()
     */
    void static digitalWriteRGB(uint8_t color, uint8_t val);

    /** \brief
     * Initialize the Arduboy's hardware.
     *
     * \details
     * This function initializes the display, buttons, etc.
     *
     * This function is called by begin() so isn't normally called within a
     * sketch. However, in order to free up some code space, by eliminating
     * some of the start up features, it can be called in place of begin().
     * The functions that begin() would call after boot() can then be called
     * to add back in some of the start up features, if desired.
     * See the README file or documentation on the main page for more details.
     *
     * \see Arduboy2Base::begin()
     */
    void static boot();

    /** \brief
     * Delay for the number of milliseconds, specified as a 16 bit value.
     *
     * \param ms The delay in milliseconds.
     *
     * \details
     * This function works the same as the Arduino `delay()` function except
     * the provided value is 16 bits long, so the maximum delay allowed is
     * 65535 milliseconds (about 65.5 seconds). Using this function instead
     * of Arduino `delay()` will save a few bytes of code.
     */
    void static delayShort(uint16_t ms) __attribute__ ((noinline));

    /** \brief
     * The counter used by the `timer()` function to time the duration of a tone.
     *
     * \details
     * This variable is set by the `dur` parameter of the `tone()` function.
     * It is then decremented each time the `timer()` function is called, if its
     * value isn't 0. When `timer()` decrements it to 0, a tone that is playing
     * will be stopped.
     *
     * A sketch can determine if a tone is currently playing by testing if
     * this variable is non-zero (assuming it's a timed tone, not a continuous
     * tone).
     *
     * Example:
     * \code{.cpp}
     * beep.tone(beep.freq(1000), 15);
     * while (beep.duration != 0) { } // wait for the tone to stop playing
     * \endcode
     *
     * It can also be manipulated directly by the sketch, although this should
     * seldom be necessary.
     */
    static uint16_t duration;
    static bool tonesPlaying;
    static uint16_t toneSequence[];
    static uint16_t duration2;
    static bool tonesPlaying2;
    static uint16_t toneSequence2[];

    /** \brief
     * Play a tone for a given duration.
     *
     * \param count The count to be loaded into the timer/counter to play
     *              the desired frequency.
     * \param dur The duration of the tone, used by `timer()`.
     *
     * \details
     * A tone is played for the specified duration, or until replaced by another
     * tone or stopped using `noTone()`.
     *
     * The tone's frequency is determined by the specified count, which is loaded
     * into the timer/counter that generates the tone. A desired frequency can be
     * converted into the required count value using the `freq()` function.
     *
     * The duration value is the number of times the `timer()` function must be
     * called before the tone is stopped.
     *
     * \see freq() timer() noTone()
     */
    static void tone(const uint16_t freq, const uint16_t dur);
    static void tone(const uint16_t *tones);
    static void tone2(const uint16_t freq, const uint16_t dur);
    static void tone2(const uint16_t *tones);

    /** \brief
     * Handle the duration that a tone plays for.
     *
     * \details
     * This function must be called at a constant interval, which would normally
     * be once per frame, in order to stop a tone after the desired tone duration
     * has elapsed.
     *
     * If the value of the `duration` variable is not 0, it will be decremented.
     * When the `duration` variable is decremented to 0, a playing tone will be
     * stopped.
     */
    static void timer();
    static void noTone();
    static void timer2();
    static void noTone2();

    static uint8_t readEEPROM(uint16_t address);
    static void readEEPROM(uint16_t address, void *data_dest, size_t size);
    static void writeEEPROM(uint16_t address, uint8_t value);
    static void writeEEPROM(uint16_t address, void *data_source, size_t size);

  protected:
    // internals
    void static bootPins();
};

#endif
