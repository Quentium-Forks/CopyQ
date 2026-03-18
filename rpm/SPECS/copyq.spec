Name:       copyq
Version:    13.0.0.5
Release:    1%{?dist}
Summary:    Advanced clipboard manager

License:    GPLv3+
URL:        https://hluk.github.io/CopyQ/
Source0:    %{name}-%{version}.tar.gz

%description
CopyQ is an advanced clipboard manager with powerful editing and scripting features.
CopyQ monitors system clipboard and saves its content in customized tabs.
Saved clipboard can be later copied and pasted directly into any application.

%prep
%setup -q

%build
# Check if qca dependencies are installed
if rpm -q qca-qt6-devel; then
    EXTRA_FLAGS="-DWITH_QCA_ENCRYPTION=ON"
else
    EXTRA_FLAGS="-DWITH_QCA_ENCRYPTION=OFF"
fi
# Check if miniaudio dependencies are installed
if rpm -q miniaudio-devel; then
    EXTRA_FLAGS="$EXTRA_FLAGS -DWITH_AUDIO=ON"
else
    EXTRA_FLAGS="$EXTRA_FLAGS -DWITH_AUDIO=OFF"
fi
# Check if kf6 dependencies are installed
if rpm -q kf6-kguiaddons-devel; then
    EXTRA_FLAGS="$EXTRA_FLAGS -DWITH_NATIVE_NOTIFICATIONS=ON"
else
    EXTRA_FLAGS="$EXTRA_FLAGS -DWITH_NATIVE_NOTIFICATIONS=OFF"
fi

cmake -S . -B build \
    -DCMAKE_INSTALL_PREFIX=%{_prefix} \
    -DPLUGIN_INSTALL_PREFIX=%{_libdir}/%{name}/plugins \
    -DTRANSLATION_INSTALL_PREFIX=%{_datadir}/%{name}/locale \
    -DCMAKE_BUILD_TYPE=Release \
    $EXTRA_FLAGS

cmake --build build -j $(nproc)

%install
rm -rf %{buildroot}

DESTDIR=%{buildroot} cmake --install build

%find_lang %{name} --with-qt

%check
if command -v desktop-file-validate >/dev/null 2>&1; then
    desktop-file-validate %{buildroot}%{_datadir}/applications/com.github.hluk.%{name}.desktop
fi
if command -v appstream-util >/dev/null 2>&1; then
    appstream-util validate-relax --nonet %{buildroot}%{_datadir}/metainfo/com.github.hluk.%{name}.metainfo.xml
fi

%files -f %{name}.lang
%doc AUTHORS CHANGES.md HACKING README.md
%license LICENSE
%{_bindir}/%{name}
%{_libdir}/%{name}/
%{_datadir}/bash-completion/completions/%{name}
%{_datadir}/metainfo/com.github.hluk.%{name}.metainfo.xml
%{_datadir}/applications/com.github.hluk.%{name}.desktop
%dir %{_datadir}/icons/hicolor/*/
%dir %{_datadir}/icons/hicolor/*/apps/
%{_datadir}/icons/hicolor/*/apps/%{name}*.png
%{_datadir}/icons/hicolor/*/apps/%{name}*.svg
%dir %{_datadir}/%{name}/
%dir %{_datadir}/%{name}/locale/
%{_datadir}/%{name}/themes/
%{_datadir}/gnome-shell/extensions/%{name}-clipboard@hluk.github.com/
%{_mandir}/man1/%{name}.1.*

%changelog
