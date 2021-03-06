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
package alphatab.model;

/**
 * The score is the root node of the complete 
 * model. It stores the basic information of 
 * a song and stores the sub components. 
 */
class Score 
{
    private var _currentRepeatGroup:RepeatGroup;
    
    /**
     * The album of this song. 
     */
    public var album:String;
    /**
     * The artist who performs this song.
     */
    public var artist:String;
    /**
     * The owner of the copyright of this song. 
     */
    public var copyright:String;
    /**
     * Additional instructions 
     */
    public var instructions:String;
    /**
     * The author of the music. 
     */
    public var music:String;
    /**
     * Some additional notes about the song. 
     */
    public var notices:String;
    /**
     * The subtitle of the song. 
     */
    public var subTitle:String;
    /**
     * The title of the song. 
     */
    public var title:String;
    /**
     * The author of the song lyrics
     */
    public var words:String;    
    /**
     * The author of this tablature. 
     */
    public var tab:String;

    public var tempo:Int;
    public var tempoLabel:String;
    
    public var masterBars:Array<MasterBar>;
    public var tracks:Array<Track>;
    
    public function new() 
    {
        masterBars = new Array<MasterBar>();
        tracks = new Array<Track>();
        _currentRepeatGroup = new RepeatGroup();
    }
    
    public function addMasterBar(bar:MasterBar)
    {
        bar.score = this;
        bar.index = masterBars.length;
        if (masterBars.length != 0)
        {
            bar.previousMasterBar = masterBars[masterBars.length - 1];
            bar.previousMasterBar.nextMasterBar = bar;
            bar.start = bar.previousMasterBar.start + bar.previousMasterBar.calculateDuration();
        }
        
        // if the group is closed only the next upcoming header can
        // reopen the group in case of a repeat alternative, so we 
        // remove the current group 
        if (bar.isRepeatStart || (_currentRepeatGroup.isClosed && bar.alternateEndings <= 0))
        {
            _currentRepeatGroup = new RepeatGroup();
        }
        _currentRepeatGroup.addMasterBar(bar);
        masterBars.push(bar);
    }
    
    public function addTrack(track:Track)
    {
        track.score = this;
        track.index = tracks.length;
        tracks.push(track);
    }
    
    public function finish()
    {
        for (t in tracks)
        {
            t.finish();
        }
    }
}