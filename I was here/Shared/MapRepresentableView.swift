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
    var polylines: [MKPolyline] = []
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
        view.addOverlays(polylines)
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
            if overlay is MKPolyline {
                let renderer = MKPolylineRenderer(overlay: overlay)
                renderer.strokeColor = .blue
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
}
#else
struct MapRepresentableView: NSViewRepresentable {
    @Binding var region: MKCoordinateRegion
        var overlays: [MKOverlay]
        var polylines: [MKPolyline]
        var annotations: [MKAnnotation]

        func makeNSView(context: Context) -> MKMapView {
            let mapView = MKMapView()
            mapView.delegate = context.coordinator
            return mapView
        }

        func updateNSView(_ nsView: MKMapView, context: Context) {
            nsView.setRegion(region, animated: true)
            nsView.addOverlays(overlays)
            nsView.addOverlays(polylines)
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
                if overlay is MKPolyline {
                    let renderer = MKPolylineRenderer(overlay: overlay)
                    renderer.strokeColor = .blue
                    return renderer
                }
                return MKOverlayRenderer()
            }
        }
    }
#endif


