//
//  DetailView.swift
//  TattooSchedule
//
//  Created by Jaejun Shin on 14/6/2022.
//

import SwiftUI
import PhotosUI

struct DetailView: View {
    @FocusState private var focusedField: Field?

    @EnvironmentObject var dataController: DataController
    @Environment(\.dismiss) var dismiss

    @ObservedObject var schedule: Schedule

    @ObservedObject var imagePicker = ImagePicker()

    let columns = [GridItem(.adaptive(minimum: 100))]

    @State private var name: String
    @State private var date: Date
    @State private var design: String
    @State private var comment: String
    @State private var designPhoto: Data?

    init(schedule: Schedule) {
        self.schedule = schedule

        _name = State(wrappedValue: schedule.scheduleName)
        _date = State(wrappedValue: schedule.scheduleDate)
        _design = State(wrappedValue: schedule.scheduleDesign)
        _comment = State(wrappedValue: schedule.scheduleComment)
        _designPhoto = State(wrappedValue: schedule.designPhoto)
    }

    @State private var showingEditMode = false
    @State private var showingDeleteAlert = false

    var editModeView: some View {
        Group {
            Section {
                DatePicker("Select the date", selection: $date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .onAppear {
                        UIDatePicker.appearance().minuteInterval = 30
                    }
            } header: {
                Text("Date")
            }

            Section {
                TextField(design, text: $design)
                    .focused($focusedField, equals: .design)
                    .submitLabel(.done)

                TextField(comment, text: $comment)
                    .focused($focusedField, equals: .comment)
                    .submitLabel(.done)
            } header: {
                Text("Design & Comment")
            }

            HStack {
                PhotosPicker(
                    selection: $imagePicker.imageSelections,
                    maxSelectionCount: 10,
                    matching: .images,
                    preferredItemEncoding: .automatic,
                    photoLibrary: .shared()
                ) {
                    HStack {
                        Text("Photos")
                        Image(systemName: "photo.stack")
                    }
                }
            }

            Button {
                switchViews()
            } label: {
                Text(showingEditMode ? "Save" : "Edit")
            }
        }
    }

    var detailView: some View {
        Group {
            Section {
                Text(schedule.scheduleDate , style: .date)
                    .font(.title)
                Text(schedule.scheduleDate , style: .time)
                    .font(.title)
            } header: {
                Text("Time")
            }

            Section {
                Text(schedule.scheduleDesign)
                    .font(.title)

                Text(schedule.scheduleComment)
                    .font(.title)
            } header: {
                Text("Design & Comment")
            }

            Section {
                
            } header: {
                Text("Photo")
            }

            Button {
                switchViews()
            } label: {
                Text(showingEditMode ? "Save" : "Edit")
            }

        }
    }
    
    var body: some View {
        Form {
            if !showingEditMode {
                detailView
            } else {
                editModeView
            }
        }
        .navigationTitle(schedule.scheduleName)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            Button {
                showingDeleteAlert = true
            } label: {
                Label("Delete the schedule", systemImage: "trash")
            }
        }
        .alert("Delete this Schedule?", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive, action: deleteSchedule)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you really sure?")
        }
        .onSubmit {
            switch focusedField {
            case .design:
                focusedField = .comment
            default:
                print("Text Field Editing…")
            }
        }
        .scrollDismissesKeyboard(.immediately)
    }

    func switchViews() {
        if showingEditMode {
            saveEditedSchedule(schedule)
            showingEditMode.toggle()
        } else {
            showingEditMode.toggle()
        }
    }

    func saveEditedSchedule(_ schedule: Schedule) {
        schedule.name = name
        schedule.date = date
        schedule.design = design
        schedule.comment = comment
        if let selectedImage = imagePicker.image {
            let data = selectedImage.jpegData(compressionQuality: 1.0)
            schedule.designPhoto = data
        }

        dataController.save()
    }
    
    func deleteSchedule() {
        dataController.delete(schedule)
        dataController.save()
        dismiss()
    }
}

