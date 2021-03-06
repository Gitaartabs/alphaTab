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
package alphatab.rendering.glyphs;

import alphatab.model.Beat;
import alphatab.model.Note;
import alphatab.model.TextBaseline;
import alphatab.platform.ICanvas;
import alphatab.rendering.Glyph;
import alphatab.rendering.TabBarRenderer;
import alphatab.rendering.utils.BeamingHelper;
import haxe.ds.IntMap;
import haxe.ds.StringMap;

class TabNoteChordGlyph extends Glyph
{
    private var _notes:Array<NoteNumberGlyph>;
    private var _noteLookup:IntMap<NoteNumberGlyph>;
    private var _minNote:Note;
    private var _isGrace:Bool;
    private var _centerX:Int;
    
    public var beat:Beat;
    public var beamingHelper:BeamingHelper;    
    public var beatEffects:StringMap<Glyph>;
    
    public function new(x:Int = 0, y:Int = 0, isGrace:Bool) 
    {
        super(x, y);
        _notes = new Array<NoteNumberGlyph>();
        beatEffects = new StringMap<Glyph>();
        _noteLookup = new IntMap<NoteNumberGlyph>();
    }
    
    public function getNoteX(note:Note, onEnd:Bool = true) 
    {
        if (_noteLookup.exists(note.string)) 
        {
            var n = _noteLookup.get(note.string);
            var pos = x + n.x + Std.int(NoteNumberGlyph.Padding * getScale());
            if (onEnd) 
            {
                n.calculateWidth();
                pos += n.width;
            }
            return pos;
        }
        return 0;
    }
    
    public function getNoteY(note:Note) 
    {
        if (_noteLookup.exists(note.string)) 
        {
            return y + _noteLookup.get(note.string).y;
        }
        return 0;
    }
    
    public override function doLayout():Void 
    {
        var w = 0;
        for (g in _notes)
        {
            g.renderer = renderer;
            g.doLayout();
            if (g.width > w)
            {
                w = g.width;
            }
        }
        
        var tabRenderer:TabBarRenderer = cast renderer;
        var tabHeight = renderer.getResources().tablatureFont.getSize();
        var effectY = Std.int(getNoteY(_minNote) + tabHeight / 2);
         // TODO: take care of actual glyph height
        var effectSpacing:Int = Std.int(7 * getScale());
        for (g in beatEffects)
        {
            g.y = effectY;
            g.x = Std.int(width / 2);
            g.renderer = renderer;
            effectY += effectSpacing;
            g.doLayout();
        }
        
        _centerX = 0;
        
        width = w;
    }
    
    public function addNoteGlyph(noteGlyph:NoteNumberGlyph, note:Note)
    {
        _notes.push(noteGlyph);
        _noteLookup.set(note.string, noteGlyph);
        if (_minNote == null || note.string < _minNote.string) _minNote = note;
    }    
    
    public override function paint(cx:Int, cy:Int, canvas:ICanvas):Void 
    {
        var res = renderer.getResources();
        var old = canvas.getTextBaseline();
        canvas.setTextBaseline(TextBaseline.Middle);
        canvas.setColor(res.mainGlyphColor);
        if (_isGrace) 
        {
            canvas.setFont(res.graceFont);            
        }
        else
        {
            canvas.setFont(res.tablatureFont);
        }
        for (g in _notes)
        {
            g.renderer = renderer;
            g.paint(cx + x, cy + y, canvas);
        }
        canvas.setTextBaseline(old);
        
        for (g in beatEffects)
        {
            g.paint(cx + x, cy + y, canvas);
        }
    }

    public function updateBeamingHelper(cx:Int) : Void
    { 
        if (!beamingHelper.hasBeatLineX(beat))
        {
            beamingHelper.registerBeatLineX(beat, cx + x + _centerX, cx + x + _centerX);             
        }
    }    
}