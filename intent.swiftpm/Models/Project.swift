import SwiftUI
import Foundation

// MARK: - Project Model
/// Represents a photography project containing an original image and its cropped frames
struct Project: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var dateCreated: Date
    var originalImageData: Data
    var frames: [Frame]
    
    init(name: String = "Untitled Project", originalImageData: Data) {
        self.name = name
        self.dateCreated = Date()
        self.originalImageData = originalImageData
        self.frames = []
    }
    
    /// Returns the original image as UIImage
    var originalImage: UIImage? {
        UIImage(data: originalImageData)
    }
    
    // Hashable conformance (hash by ID only for performance)
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Project, rhs: Project) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Project Storage Manager
/// Handles saving and loading projects from local storage
class ProjectStorage: ObservableObject {
    @Published var projects: [Project] = []
    
    private let storageKey = "intent_projects"
    private var fileURL: URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent("projects.json")
    }
    
    init() {
        loadProjects()
    }
    
    func loadProjects() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            projects = try decoder.decode([Project].self, from: data)
        } catch {
            print("Failed to load projects: \(error)")
        }
    }
    
    func saveProjects() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(projects)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save projects: \(error)")
        }
    }
    
    func addProject(_ project: Project) {
        projects.insert(project, at: 0)
        saveProjects()
    }
    
    func updateProject(_ project: Project) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index] = project
            saveProjects()
        }
    }
    
    func deleteProject(_ project: Project) {
        projects.removeAll { $0.id == project.id }
        saveProjects()
    }
    
    func deleteProject(at offsets: IndexSet) {
        projects.remove(atOffsets: offsets)
        saveProjects()
    }
    
    func renameProject(_ project: Project, to newName: String) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index].name = newName
            saveProjects()
        }
    }
}
