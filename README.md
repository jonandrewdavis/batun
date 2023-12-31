# batun - a battle game

A top down multiplayer battle game built in Godot 4.2. Just for learning and fun with friends.

## Sources:

Check out these tutorials I took bits & pieces from to learn the engine & make this game. I highly recommend several of these!

- [Itch.io free assets](https://itch.io/game-assets/free)
  - Pixel art ALL sourced from itch!
  - HUGE call out to this [FANTASTIC tile set](https://cainos.itch.io/pixel-art-top-down-basic)
  - AND! the character sprites that I cant find!
  - Sounds from [Pixabay](https://pixabay.com/sound-effects/), music from itch.io
- [Finite State Machines in Under 5 min](https://www.youtube.com/watch?v=ow_Lum-Agbs&pp=ygUaZmluaXRlIHN0YXRlIG1hY2hpbmUgZ29kb3Q%3D)
  - Best FSM tutorials around! Could not say enough good things about this strategy. It pays super dividends.
- [Godot-Roguelike-Tutorial](https://github.com/MateuSai/Godot-Roguelike-Tutorial) - Super comprehensive, especially if you want to learn inheritence and enemy PVE. Somewhat datated for 4.0.
- [Make an Action RPG in Godot 3.2](https://www.youtube.com/watch?v=mAbG8Oi-SvQ&list=PL9FzW-m48fn2SlrW0KoLT4n5egNdX-W9a&index=1)
  - The most comprehensive tutorial around. A little dated for 4.0, but teaches many of the fundamentals!
- [https://www.youtube.com/watch?v=n8D3vEx7NAE](https://www.youtube.com/watch?v=n8D3vEx7NAE&t=1995s)
  - The foundation of the networked multiplayer is in this video. Highly recommend if you're doing anything networked.

And that's it! This game is an amalgam of all of these and more. Many thanks to those who put these together!

## Host on AWS

Just saving some commands I use just in case. Follow this great guide. https://urodelagames.github.io/2022/04/19/setting-up-godot-server-on-aws/

```
scp -i [your_pem].pem [your_pck].pck ec2-user@[server_ip]:/home/ec2-user/
```

Connect via SSH. Swap out: `Godot_v4.2-beta2_linux` for your version.

```
sudo yum install wget && sudo yum install unzip && wget https://downloads.tuxfamily.org/godotengine/4.0/beta17/Godot_v4.0-beta17_linux.x86_64.zip && unzip Godot_v4.0-beta17_linux.x86_64.zip

```

Run. Swap out: `./Godot_v4.2-beta2_linux.x86_64` for your version. `--` are user args. Add server to yours in project settings.

```
./Godot_v4.2-beta2_linux.x86_64 --main-pack [your_pck].pck --headless  -- server
```

Provide your players with the IP and you're good to go!
