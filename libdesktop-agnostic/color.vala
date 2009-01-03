/* 
 * Extension to Gdk.Color which has support for an alpha channel.
 *
 * Copyright (C) 2008, 2009 Mark Lee <libdesktop-agnostic@lazymalevolence.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 *
 * Author : Mark Lee <libdesktop-agnostic@lazymalevolence.com>
 */

using Gdk;

namespace DesktopAgnostic
{
  public errordomain ColorParseError
  {
    INVALID_INPUT,
    INVALID_ALPHA
  }
  public class Color
  {
    const string HTML_STRING = "#%02hx%02hx%02hx%02hx";
    const ushort HTML_SCALE = 256;
    private Gdk.Color _color;
    public Gdk.Color color
    {
      get
      {
        return this._color;
      }
      set
      {
        this._color = value;
      }
    }
    public ushort red
    {
      get
      {
        return this._color.red;
      }
      set
      {
        this._color.red = value;
      }
    }
    public ushort green
    {
      get
      {
        return this._color.green;
      }
      set
      {
        this._color.green = value;
      }
    }
    public ushort blue
    {
      get
      {
        return this._color.blue;
      }
      set
      {
        this._color.blue = value;
      }
    }
    public ushort alpha;
    public Color (Gdk.Color color, ushort alpha)
    {
      this._color = color;
      this.alpha = alpha;
    }
    public Color.from_values (ushort red, ushort green, ushort blue, ushort alpha)
    {
      this._color = Gdk.Color ();
      this._color.red = red;
      this._color.green = green;
      this._color.blue = blue;
      this.alpha = alpha;
    }
    /**
     * @see Gdk.Color.parse
     */
    public Color.from_string (string spec) throws ColorParseError
    {
      this._color = Gdk.Color ();
      this.alpha = 0;
      string color_data;
      if (spec.get_char () == '#')
      {
        long cd_len = 0;
        GLib.message ("pound");
        weak string color_hex = spec.offset (1);
        // adapted from pango_color_parse (), licensed under the LGPL2.1+.
        cd_len = color_hex.size ();
        if (cd_len % 4 != 0 || cd_len < 4 || cd_len > 16)
        {
          throw new ColorParseError.INVALID_INPUT ("Invalid input size.");
        }
        long hex_len = cd_len / 4;
        long offset = hex_len * 3;
        string rgb_hex = color_hex.substring (0, offset);
        weak string alpha_hex = color_hex.offset (offset);
        if (alpha_hex.scanf ("%" + hex_len.to_string () + "hx", ref this.alpha) == 0)
        {
          throw new ColorParseError.INVALID_ALPHA ("Could not parse alpha section of input: %s",
                                                   alpha_hex);
        }
        ushort bits = (ushort)cd_len;
        this.alpha <<= 16 - bits;
        while (bits < 16)
        {
          this.alpha |= (this.alpha >> bits);
          bits *= 2;
        }
        color_data = "#" + rgb_hex;
      }
      else
      {
        // assume color name + no alpha
        color_data = spec;
      }
      GLib.message ("color_data: %s", color_data);
      if (!Gdk.Color.parse (color_data, out this._color))
      {
        throw new ColorParseError.INVALID_INPUT ("Could not parse color string: %s",
                                                 spec);
      }
    }
    public string
    to_html_color ()
    {
      return HTML_STRING.printf (this.red / HTML_SCALE,
                                 this.green / HTML_SCALE,
                                 this.blue / HTML_SCALE,
                                 this.alpha / HTML_SCALE);
    }
    /**
     * Behaves the same as Gdk.Color.to_string (), except that it adds
     * alpha data.
     * @see Gdk.Color.to_string
     */
    public string
    to_string ()
    {
      weak string gdk_str = this._color.to_string ();
      return "%s%04x".printf (gdk_str, this.alpha);
    }
  }
}

// vim: set et ts=2 sts=2 sw=2 ai :
