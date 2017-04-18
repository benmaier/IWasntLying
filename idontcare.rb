use_bpm 128

glass_notes = [:Fs3, :A3, :E3, :Cs3].ring

vol_hiss = 0.2
vol_snr = 2
vol_cym = 2
vol_hh = 2
vol_glass = 2
vol_rpg = 2
vol_bass = 2
vol_bd = 2
vol_octv = 2
is_break = false

vol_break_voice = 0
voice_switch = 0
vol_oah = 2 * voice_switch
vol_aah = 3 * voice_switch
vol_low_voice = 5 * voice_switch
vol_std_voice = 3 * voice_switch

glass_hpf_mix = 0.7

# global variable for total count of quarter notes
$total_beats

chiplead_transpose = 7

live_loop :beat_counter do
  $total_beats = 0
  loop do
    sleep 1
    $total_beats += 1
    print 'total quarter notes: ' + $total_beats.to_s
    if $total_beats % (16*4) >= 12*4
      print "approaching new 16block in: " + (16*4-$total_beats % (16*4)).to_s
    end
  end
end

live_loop :bd do
  cue :beat_counter
  if vol_bd>0
    14.times do
      sample :bd_haus, amp: 4*vol_bd
      sleep 1
    end
    if rrand_i(0,1) == 0
      sample :bd_haus, amp: 4*vol_bd
      sleep 3/4.0
      sample :bd_haus, amp: 4*vol_bd
      sleep 3/4.0
      sample :bd_haus, amp: 4*vol_bd
      sleep 2/4.0
    else
      2.times do
        sample :bd_haus, amp: 4*vol_bd
        sleep 1
      end
    end
  else
    sleep 16
  end
end

with_fx :reverb, mix: 0.5, room: 1 do
  live_loop :glass do
    cue :bd
    use_synth :dark_ambience
    if vol_glass>0
      with_fx :hpf, mix: glass_hpf_mix, cutoff: scale_linear($total_beats,16,90,50) do
        4.times do
          play glass_notes.tick, amp: 1.5*3*vol_glass, pan: -0.3, release: 2, sustain: 0.5
          play :Fs4, amp: 0.75*3*vol_glass, pan: 0.5, release: 2, sustain: 0.5
          play :Fs2, amp: 1.5*3*vol_glass, pan: 0, release: 2, sustain: 0.5
          sleep 2
        end
      end
    else
      sleep 8
    end
  end
end

with_fx :slicer, mix: 0.5 do
  with_fx :reverb, mix: 0.7, room:  0.6 do
    with_fx :octaver do
      live_loop :octv do
        cue :bd
        octv_notes = [:Fs4,:Cs3,:E3,:A3].ring
        if vol_octv>0
          12.times do
            sleep 1/2.0
            play :Fs3, amp: 0.5*vol_octv
            sleep 1/4.0
            play :Fs3, amp: 0.2*vol_octv
            sleep 1/4.0
          end
          2.times do
            this_note = octv_notes.tick
            sleep 0/2.0
            play this_note, amp: 0.5*vol_octv, pan:  rrand(-1,1)
            sleep 2/4.0
            play this_note, amp: 0.5*vol_octv, pan: rrand(-1,1)
            sleep 2/4.0
          end
          2.times do
            this_note = octv_notes.tick
            sleep 0/2.0
            play this_note, amp: 0.5*vol_octv, pan: rrand(-1,1)
            sleep 2/4.0
            play this_note, amp: 0.5*vol_octv, pan: rrand(-1,1)
            sleep 1/4.0
            play this_note, amp: 0.5*vol_octv, pan: rrand(-1,1)
            sleep 1/4.0
          end
        else
          sleep 16
        end
      end
    end
  end
end

live_loop :bass do
  cue :bd
  use_synth :tri
  if vol_bass > 0
    3.times do
      sleep 1/3.0
      play :Fs1, sustain: 1.0/8.0, decay: 1.0/16.0, release: 0.01, attack: 0.01, amp: vol_bass
      play :Fs2, sustain: 1.0/8.0, decay: 1.0/16.0, release: 0.01, attack: 0.01, amp: 0.2*vol_bass
      sleep 1/3.0
      play :Fs1, sustain: 1.0/8.0, decay: 1.0/16.0, release: 0.01, attack: 0.01, amp: vol_bass
      play :Fs2, sustain: 1.0/8.0, decay: 1.0/16.0, release: 0.01, attack: 0.01, amp: 0.2*vol_bass
      sleep 1/3.0
    end
    sleep 1/4.0
    play :A1, sustain: 1.0/8.0, decay: 1.0/16.0, release: 0.01, attack: 0.01, amp: vol_bass
    play :A2, sustain: 1.0/8.0, decay: 1.0/16.0, release: 0.01, attack: 0.01, amp: 0.2*vol_bass
    sleep 1/4.0
    play :E1, sustain: 1.0/8.0, decay: 1.0/16.0, release: 0.01, attack: 0.01, amp: vol_bass
    play :E2, sustain: 1.0/8.0, decay: 1.0/16.0, release: 0.01, attack: 0.01, amp: 0.2*vol_bass
    sleep 1/4.0
    play :Cs2, sustain: 1.0/8.0, decay: 1.0/16.0, release: 0.01, attack: 0.01, amp: vol_bass
    play :Cs3, sustain: 1.0/8.0, decay: 1.0/16.0, release: 0.01, attack: 0.01, amp: 0.2*vol_bass
    sleep 1/4.0
  else
    sleep 4
  end
end

bass_notes = [ :Fs2, :E2, :Cs2, :A2, :Fs3, :A4, :A3, :B3 ].ring
break_notes = [ :A4, :Fs2, :B3, :Fs2, :A3 , :E2, :Cs2, :Fs3, :A4, :A3, :B3 ].ring

live_loop :second_amb do
  cue :bd
  use_synth :chiplead
  
  with_fx :reverb, mix: scale_linear($total_beats,16,0,0.8), room: 1 do
    4.times do
      with_fx :lpf, cutoff: cutoff_lfo($total_beats,4) do
        4.times do
          if $total_beats % 16 >= 12
            tr = chiplead_transpose
          else
            tr = 0
          end
          
          
          if is_break
            note = break_notes.tick
          else
            note = bass_notes.tick
          end
          play note+tr, sustain: 1/64.0, release: 0.1, amp: vol_rpg
          play note+12+tr, sustain: 1/64.0, release: 0.1, amp: 0.5*vol_rpg
          sleep 1/4.0
        end
      end
    end
  end
end

with_fx :hpf, mix: 0.2, cutoff: 110 do
  with_fx :reverb, mix: 0.8, room: 0.5 do
    with_fx :echo,
      mix: 0.01,
      rate: 1*3.0/4.0,
    decay: 4*1 do
      
      live_loop :snr do
        cue :bd
        if vol_snr >0
          2.times do
            7.times do
              sleep 1
              sample :sn_dolf, amp: 1*vol_snr, rate: 0.9
              sleep 1
            end
            1.times do
              with_fx :echo,
                mix: 0.01,
                rate: 1*3.0/4.0,
              decay: 4*1 do
                sleep 1
                sample :sn_dolf, amp: 1*vol_snr, rate: 0.9
              end
              sleep 3.0*1/4.0
              sample :sn_dolf, amp: 1*vol_snr, rate: 0.9
              sleep 1.0*1/4.0
            end
          end
        else
          #if vol==0
          sleep 4
        end
      end
    end
  end
end

live_loop :hiss do
  cue :bd
  sleep 1/2.0
  sample :vinyl_hiss, amp: 2.0*vol_hiss,  rate: 1.0
  sleep 1/2.0
  sample :ambi_lunar_land, rate: 1.0, amp: 1.0*vol_hiss
  sleep 1/2.0
end

# 1 bar
with_fx :reverb, mix: 0.5 do
  with_fx :echo, mix: 0.2, phase: 1/4.0 do
    
    live_loop :cym do
      cue :bd
      16.times do
        sleep 1/2.0
        sample :drum_cymbal_closed, rate: 1, amp: 0.8*vol_cym
        sleep 1/2.0
      end
    end
  end
end

# 1 bar
live_loop :hh do
  cue :bd
  16.times do
    sleep 1/4.0
    sample :drum_cymbal_closed, amp: 0.2*vol_hh
    sleep 1/2.0
    sample :drum_cymbal_closed, amp: 0.4*vol_hh
    sleep 1/4.0
  end
end

live_loop :ariana_low do
  tr = 1.0
  if vol_low_voice>0 or vol_break_voice>0
    
    2.times do
      sample "/Users/bfmaier/music/sonic_pi/lying/baby_i_dont_care.wav", rate: 2**((tr-24)/12), amp: 0.3*vol_low_voice, pan: rrand(-1,1)
      sample "/Users/bfmaier/music/sonic_pi/lying/yaheeahee.wav", rate: 2**((tr)/12), amp: 7*vol_break_voice, pan: rrand(-1,1)
      sleep 4
      sample "/Users/bfmaier/music/sonic_pi/lying/i_wasnt_lying.wav", rate: 2**((tr-12)/12), amp: 0.4*vol_low_voice, pan: rrand(-1,1)
      sleep 0
      with_fx :panslicer, mix: 0.5, phase: 3/4.0 do
        sample "/Users/bfmaier/music/sonic_pi/lying/so_one_last.wav", rate: 2**((tr-12)/12), amp: 1.5*vol_break_voice, pan: rrand(-1,1)
      end
      sleep 4
    end
  else
    sleep 2*8
  end
end

with_fx :reverb, mix: 0.6, room: 0.8 do
 live_loop :ariana do
  cue :bd
  tr = 1.0
  if vol_std_voice>0 or vol_aah>0 or vol_oah>0

       2.times do
        sample "/Users/bfmaier/music/sonic_pi/lying/its_a_bee.wav", rate: 2**(tr/12), amp: 0.4*vol_std_voice
        sample "/Users/bfmaier/music/sonic_pi/lying/oah.wav", rate: 2**(tr/12), amp: 0.8*vol_oah, pan: rrand(-0.5,0.5)
        sample "/Users/bfmaier/music/sonic_pi/lying/aah.wav", rate: 2**(tr/12), amp: 4*vol_aah, pan: -1
        sleep 1
        sample "/Users/bfmaier/music/sonic_pi/lying/oah.wav", rate: 2**(tr/12), amp: 0.8*vol_oah, pan: rrand(-0.5,0.5)
        sleep 1
        sample "/Users/bfmaier/music/sonic_pi/lying/oah.wav", rate: 2**(tr/12), amp: 0.8*vol_oah, pan: rrand(-0.5,0.5)
        sleep 1
        sample "/Users/bfmaier/music/sonic_pi/lying/oah.wav", rate: 2**(tr/12), amp: 0.8*vol_oah, pan: rrand(-0.5,0.5)
        sleep 1
        sample "/Users/bfmaier/music/sonic_pi/lying/i_wasnt_lying.wav", rate: 2**(tr/12), amp: 0.8*vol_std_voice, pan: rrand(-1,1)
        sleep 10/4.0
        sample "/Users/bfmaier/music/sonic_pi/lying/baby_i_dont_care.wav", rate: 2**(tr/12), amp: 0.3*vol_std_voice, pan: rrand(-1,1)
        sleep 6/4.0
       end
  else
    sleep 2*8
  end
 end
end

def cutoff_lfo  (beats, n_bars)
  length = n_bars * 4
  return 3*(beats % length) + 70
end

def scale_linear(current_beat, n_bars, start_at, finish_at)
  length = n_bars * 4
  a = start_at
  b = finish_at
  return (b-a) * (current_beat % length) / (length.to_f-1) + a
end