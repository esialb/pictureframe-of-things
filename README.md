# Pictureframe of Things

*internet-accessible (and -updateable) e-paper display, powered by
[Onion Omega](https://onion.io/), and mounted in a classy frame*

![picture frame](_www_epaper/frame.jpg)

## parts required

* [Onion Omega](https://onion.io/product/omega/)
  -- *Primary IoT controller device*
* [Mini Dock](https://onion.io/product/mini-dock/)
  -- *Power and USB connectivity*
* [Waveshare 4.3" e-Paper display](https://www.amazon.com/gp/product/B00VV5IMN0/)
  -- *Fancy e-Paper display with serial control interface*
* [CP2102 USB to TTL serial adapter](https://www.amazon.com/dp/B00LODGRV8/)
  -- *USB serial port to control the display*
* A classy picture frame, plastic foam, and tape for mounting
  -- *Because being classy matters*

## additional requirements

If you want to expose your Pictureframe-of-Things to the public
internet, you'll need a server somewhere that can proxy requests back
to the Onion Omega.  In my case, my Onion Omega makes an ssh tunnel to a
dedicated server, which uses name-based virtual hosting to proxy all
requests for [www.pictureframeofthings.com](http://www.pictureframeofthings.com/)
back to the Onion Omega's lighttpd server.

If you don't care about exposing it to the internet, it will still be
available for updates on your LAN, as well as over the Onion Omega's
built in wifi access point.

## noteable gotcha's

* **truncated serial output issues**

  For some reason that I could not discover despite spending many hours trying,
  my Onion Omega seems to be ignoring `O_SYNC` and `fsync(int)` when writing
  to `/dev/ttyUSB0`, but apparently only when the standard input to the
  display update tool was a pipe and not a `tty` nor a `pty`.  So, when
  the tool tried to close its filehandle for `/dev/ttyUSB0`, the serial output
  buffers were getting flushed (rather than drained) no matter what I tried.

  The solution to this was to just add `cat /dev/ttyUSB0 > /dev/null &` to
  `/etc/rc.local`, which forces the USB serial port to remain open at all times,
  and thus avoiding the data truncation issue.

* **`gcc` via `opkg` doesn't fit on an Onion Omega**

  This issue wasn't too terribly hard to get around.  Since I have two Onion
  Omegas, I used one of them as my "build machine".  In that one I plugged in
  a 12GB flash drive formatted `ext4`, copied `/usr` to the drive, then
  mounted with `--bind` on top of `/usr`.  This resulted in there being
  plenty of space on `/usr` for `gcc`.

  ```
mount /dev/sda1 /flash
cp -Rp /usr /flash
mount --bind /flash/usr /usr
  ```

  After those commands, I was able to install `gcc` using
  `opkg install gcc --force-space`.
