// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/material.dart';

import 'page.dart';

final LatLngBounds sydneyBounds = LatLngBounds(
  southwest: const LatLng(-34.022631, 150.620685),
  northeast: const LatLng(-33.571835, 151.325952),
);

class MapUiPage extends ExamplePage {
  MapUiPage() : super(const Icon(Icons.map), 'User interface');

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: const MapUiBody());
  }
}

class MapUiBody extends StatefulWidget {
  const MapUiBody();

  @override
  State<StatefulWidget> createState() => MapUiBodyState();
}

class MapUiBodyState extends State<MapUiBody> {
  MapUiBodyState();

  static final CameraPosition _kInitialPosition = const CameraPosition(
    target: LatLng(-33.852, 151.211),
    zoom: 3,
  );

  CameraPosition _position = _kInitialPosition;
  bool _isMapCreated = false;
  bool _isMoving = false;
  bool _compassEnabled = false;
  bool _myLocationButtonEnabled = false;
  MinMaxZoomPreference _minMaxZoomPreference = MinMaxZoomPreference.unbounded;
  MapType _mapType = MapType.standard;
  bool _rotateGesturesEnabled = false;
  bool _scrollGesturesEnabled = false;
  bool _pitchGesturesEnabled = false;
  bool _zoomGesturesEnabled = false;
  bool _myLocationEnabled = false;
  TrackingMode _trackingMode = TrackingMode.none;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _compassToggler() {
    return TextButton(
      child: Text('${_compassEnabled ? 'disable' : 'enable'} compass'),
      onPressed: () {
        setState(() {
          _compassEnabled = !_compassEnabled;
        });
      },
    );
  }

  Widget _zoomBoundsToggler() {
    return TextButton(
      child: Text(_minMaxZoomPreference.minZoom == null
          ? 'bound zoom'
          : 'release zoom'),
      onPressed: () {
        setState(() {
          _minMaxZoomPreference = _minMaxZoomPreference.minZoom == null
              ? const MinMaxZoomPreference(12.0, 16.0)
              : MinMaxZoomPreference.unbounded;
        });
      },
    );
  }

  Widget _mapTypeCycler() {
    final MapType nextType =
        MapType.values[(_mapType.index + 1) % MapType.values.length];
    return TextButton(
      child: Text('change map type to $nextType'),
      onPressed: () {
        setState(() {
          _mapType = nextType;
        });
      },
    );
  }

  Widget _rotateToggler() {
    return TextButton(
      child: Text('${_rotateGesturesEnabled ? 'disable' : 'enable'} rotate'),
      onPressed: () {
        setState(() {
          _rotateGesturesEnabled = !_rotateGesturesEnabled;
        });
      },
    );
  }

  Widget _scrollToggler() {
    return TextButton(
      child: Text('${_scrollGesturesEnabled ? 'disable' : 'enable'} scroll'),
      onPressed: () {
        setState(() {
          _scrollGesturesEnabled = !_scrollGesturesEnabled;
        });
      },
    );
  }

  Widget _tiltToggler() {
    return TextButton(
      child: Text('${_pitchGesturesEnabled ? 'disable' : 'enable'} tilt'),
      onPressed: () {
        setState(() {
          _pitchGesturesEnabled = !_pitchGesturesEnabled;
        });
      },
    );
  }

  Widget _zoomToggler() {
    return TextButton(
      child: Text('${_zoomGesturesEnabled ? 'disable' : 'enable'} zoom'),
      onPressed: () {
        setState(() {
          _zoomGesturesEnabled = !_zoomGesturesEnabled;
        });
      },
    );
  }

  Widget _myLocationToggler() {
    return TextButton(
      child: Text(
          '${_myLocationEnabled ? 'disable' : 'enable'} my location annotation'),
      onPressed: () {
        setState(() {
          _myLocationEnabled = !_myLocationEnabled;
        });
      },
    );
  }

  Widget _myLocationButtonToggler() {
    return TextButton(
      child: Text(
          '${_myLocationButtonEnabled ? 'disable' : 'enable'} my location button'),
      onPressed: () {
        setState(() {
          _myLocationButtonEnabled = !_myLocationButtonEnabled;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppleMap appleMap = AppleMap(
      onMapCreated: onMapCreated,
      trackingMode: _trackingMode,
      initialCameraPosition: _kInitialPosition,
      compassEnabled: _compassEnabled,
      minMaxZoomPreference: _minMaxZoomPreference,
      mapType: MapType.satellite,
      rotateGesturesEnabled: _rotateGesturesEnabled,
      scrollGesturesEnabled: _scrollGesturesEnabled,
      pitchGesturesEnabled: _pitchGesturesEnabled,
      zoomGesturesEnabled: _zoomGesturesEnabled,
      myLocationEnabled: _myLocationEnabled,
      myLocationButtonEnabled: _myLocationButtonEnabled,
      padding: const EdgeInsets.all(10),
      onCameraMove: _updateCameraPosition,
    );

    final List<Widget> columnChildren = <Widget>[
      Expanded(child: appleMap),
    ];

    if (_isMapCreated) {
      columnChildren.addAll([
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text('camera bearing: ${_position.heading}'),
              Text(
                  'camera target: ${_position.target.latitude.toStringAsFixed(4)},'
                  '${_position.target.longitude.toStringAsFixed(4)}'),
              Text('camera zoom: ${_position.zoom}'),
              Text('camera tilt: ${_position.pitch}'),
              Text(_isMoving ? '(Camera moving)' : '(Camera idle)'),
              Wrap(
                alignment: WrapAlignment.spaceEvenly,
                children: <Widget>[
                  _compassToggler(),
                  _mapTypeCycler(),
                  _zoomBoundsToggler(),
                  _rotateToggler(),
                  _scrollToggler(),
                  _tiltToggler(),
                  _zoomToggler(),
                  _myLocationToggler(),
                  _myLocationButtonToggler(),
                  FloatingActionButton(onPressed: () {
                    if (timer == null){
                      timer =
                          Timer.periodic(Duration(milliseconds: 100), (timer) {
                            heading += 0.5;
                            _controller?.moveCamera(CameraUpdate.updateHeading(
                                heading % 360));
                          });
                  } else{
                      timer?.cancel();
                      timer = null;
                    }
                  }),
                ],
              ),
            ],
          ),
        ),
      ]);
    }
    return Column(children: columnChildren);
  }

  Timer? timer;
  double heading = 0;

  void _updateCameraPosition(CameraPosition position) {
    setState(() {
      _position = position;
    });
  }

  AppleMapController? _controller;
  void onMapCreated(AppleMapController controller) {
    _controller = controller;
    setState(() {
      _isMapCreated = true;
    });
  }
}
