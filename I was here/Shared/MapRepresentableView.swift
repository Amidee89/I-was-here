//
//  MapRepresentableView.swift
//  I was here
//
//  Created by Marco Carandente on 15.7.2023.
//
import Foundation
import SwiftUI
import MapKit
#if os(iOS)
struct MapRepresentableView: UIViewRepresentable {

    @Binding var region: MKCoordinateRegion
    var overlays: [MKOverlay]
    var annotations: [MKAnnotation]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        view.setRegion(region, animated: true)
        view.addOverlays(overlays)
        view.addAnnotations(annotations)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapRepresentableView

        init(_ parent: MapRepresentableView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            // This is a placeholder, you need to return a proper MKOverlayRenderer based on the overlay type
            return MKOverlayRenderer()
        }
    }
}
#else
struct MapRepresentableView: NSViewRepresentable {
    @Binding var region: MKCoordinateRegion
        var overlays: [MKOverlay]
        var annotations: [MKAnnotation]

        func makeNSView(context: Context) -> MKMapView {
            let mapView = MKMapView()
            mapView.delegate = context.coordinator
            return mapView
        }

        func updateNSView(_ nsView: MKMapView, context: Context) {
            nsView.setRegion(region, animated: true)
            nsView.addOverlays(overlays)
            nsView.addAnnotations(annotations)
        }

        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }

        class Coordinator: NSObject, MKMapViewDelegate {
            var parent: MapRepresentableView

            init(_ parent: MapRepresentableView) {
                self.parent = parent
            }

            func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
                // This is a placeholder, you need to return a proper MKOverlayRenderer based on the overlay type
                return MKOverlayRenderer()
            }
        }
    }
#endif


