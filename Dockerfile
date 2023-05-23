FROM menci/archlinuxarm:base-devel

RUN pacman -Syu --noconfirm && pacman -S git go distcc --noconfirm

# non-root user for builds
RUN useradd -m -G wheel build && passwd -d build
RUN echo 'build ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
USER build
WORKDIR /home/build
RUN git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm
RUN yay -S aur/distccd-alarm-armv8 --noconfirm

USER root
COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
RUN pacman -S clang --noconfirm

EXPOSE 3632
ENV DISTCCD_JOBS=$DISTCCD_JOBS
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
