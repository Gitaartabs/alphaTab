/*
 * This file is part of alphaTab.
 * Copyright c 2013, Daniel Kuschny and Contributors, All rights reserved.
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3.0 of the License, or at your option any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library.
 */
package alphatab.audio.model;

import haxe.io.Bytes;
import haxe.io.Output;

/**
 * Represents a midi message. 
 */
class MidiMessage
{
    public var event:MidiEvent;
    
    /**
     * The raw midi message data
     */
    public var data:Bytes;

    public function new(data:Bytes) 
    {
        this.data = data;
    }
    
    public function writeTo(out:Output)
    {
        out.write(data);
    }
    
    public static function fromArray(data:Array<Int>)
    {
        var bytes = Bytes.alloc(data.length);
        for (i in 0 ... data.length)
        {
            bytes.set(i, data[i]);
        }
        return new MidiMessage(bytes);
    }
}