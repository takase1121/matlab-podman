FROM mathworks/matlab:r2022a
ARG DEBIAN_FRONTEND=noninteractive

# delete xfce4
RUN sudo apt-get remove -y xscreensaver* xfce4* \
	&& sudo apt-get autoremove -y && sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/*

# install openbox and feh
RUN sudo apt-get update && sudo apt-get install --no-install-recommends -y openbox menu \
	&& sudo apt-get autoremove -y && sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/*

# delete junk
RUN rm -rf /home/matlab/.config/xfce4 /home/matlab/Desktop

# modify xstartup to run twm, change the desktop
RUN chmod +w /home/matlab/.vnc/xstartup \
	&& sed -i 's/startxfce4/openbox-session/g' /home/matlab/.vnc/xstartup \
	&& echo "xrdb -merge \$HOME/.Xresources" >> /home/matlab/.vnc/xstartup \
	&& echo "[ ! -z \"\$TERMINATE_ON_DISCONNECT\" ] && sudo bash /bin/watch-connection.sh &" >> /home/matlab/.vnc/xstartup \
	&& echo "xterm &" >> /home/matlab/.vnc/xstartup \
	&& chmod -w /home/matlab/.vnc/xstartup

# print motd on bash (and cd to /root)
RUN echo "cat /etc/motd" >> /home/matlab/.bashrc

# patch obamenu to not use evte
RUN sudo sed -i 's/evte -e/xterm/g' /usr/bin/obamenu

# change motd to remind them to activate matlab
COPY motd /etc/motd

# copy MATLAB desktop entry because MATLAB's wouldn't work
COPY matlab.desktop /usr/share/applications/matlab.desktop
COPY matlab.xpm /usr/share/pixmaps/matlab.xpm

# copy xresources
COPY --chown=matlab:matlab Xresources /home/matlab/.Xresources

# copy connection watcher
COPY watch-connection.sh /bin/watch-connection.sh

# make connection watcher executable
RUN sudo chmod +x /bin/watch-connection.sh

# expose the vnc ports
EXPOSE 5901
EXPOSE 6080
