import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entries: [SimpleEntry] = [SimpleEntry(date: Date())]
        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct GlycoWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            // Fundo Escuro
            Color(red: 17/255, green: 17/255, blue: 17/255)
            
            VStack(spacing: 8) {
                // Título do Widget
                Text("SMARTGLYCO")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color(red: 136/255, green: 136/255, blue: 136/255))
                    .tracking(1)
                
                // Glicemia e Seta
                HStack(alignment: .center, spacing: 4) {
                    Text("115")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("➡️")
                        .font(.system(size: 24))
                }
                
                // IOB (Insulina Ativa)
                Text("IOB: 1.2 U")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(red: 0/255, green: 112/255, blue: 243/255))
            }
        }
        // No iOS 17+, isto remove o padding padrão para a cor preencher o quadrado todo
        .containerBackground(for: .widget) {
            Color(red: 17/255, green: 17/255, blue: 17/255)
        }
    }
}

@main
struct GlycoWidget: Widget {
    let kind: String = "GlycoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            GlycoWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Glicemia Atual")
        .description("Visão geral rápida da tua glicemia.")
        .supportedFamilies([.systemSmall]) // Mantém apenas o widget pequeno e quadrado
    }
}
