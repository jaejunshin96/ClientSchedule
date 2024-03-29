//
//  ScheduleListView.swift
//  TattooSchedule
//
//  Created by Jaejun Shin on 15/11/2022.
//

import SwiftUI

struct ScheduleListView: View {
    static let todayTag: String? = "Today"
    static let UpcomingTag: String? = "Upcoming"
    static let pastTag: String? = "Past"

    var navigationTitle: String

    @ObservedObject var viewModel: ViewModel
    @EnvironmentObject var dataController: DataController

    @State private var showingAddSchedule = false
    @State private var showingSearchView = false

    var body: some View {
        NavigationView {
            Group {
                if navigationTitle == "Today" {
                    if !viewModel.todaySchedules().isEmpty {
                        todayList
                    } else {
                        Text("No clients found.")
                    }
                } else if navigationTitle == "Upcoming" {
                    if !viewModel.upcomingSchedules().isEmpty {
                        upcomingList
                    } else {
                        Text("No clients found.")
                    }
                } else {
                    if !viewModel.pastSchedules().isEmpty {
                        pastList
                    } else {
                        Text("No clients found.")
                    }
                }
            }
            .navigationTitle(navigationTitle)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddSchedule.toggle()
                    } label: {
                        Label("Add Schedule", systemImage: "plus")
                    }
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSearchView.toggle()
                    } label: {
                        Label("Search for schedules", systemImage: "magnifyingglass")
                    }
                }
            }
            .sheet(isPresented: $showingAddSchedule) {
                AddScheduleView()
            }
            .sheet(isPresented: $showingSearchView) {
                ScheduleSearchView(viewModel: viewModel)
            }
            
            SelectSomethingView()
        }
        .scrollIndicators(.hidden)
    }
}

extension ScheduleListView {
    var todayList: some View {
        List {
            ForEach(viewModel.todaySchedules()) { schedule in
                NavigationLink {
                    DetailView(viewModel: viewModel, schedule: schedule)
                } label: {
                    HStack {
                        if schedule.schedulePhotos.isEmpty {
                            Image(systemName: "photo.on.rectangle")
                                .font(.largeTitle)
                                .frame(width: 60, height: 60)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(CustomColor.borderColor, lineWidth: 1)
                                )
                        } else {
                            Image(uiImage: UIImage(data: schedule.schedulePhotos.last!.schedulePhoto)!)
                                .resizable()
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(CustomColor.borderColor, lineWidth: 1)
                                )
                        }
                        
                        VStack(alignment: .leading) {
                            Text(schedule.scheduleName)
                                .font(.title2)
                                .bold()

                            Text(schedule.scheduleDate.formatted(
                                date: .numeric, time: .shortened))
                        }
                    }
                    .font(.headline)
                }
                .listRowBackground(CustomColor.listBackgroundColor)
                .contextMenu {
                    Button(role: .destructive) {
                        dataController.delete(schedule)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
    }
    
    var upcomingList: some View {
        List {
            ForEach(Array(viewModel.upcomingSchedules()), id: \.key) { week, schedules in
                Section {
                    ForEach(schedules) { schedule in
                        NavigationLink {
                            DetailView(viewModel: viewModel, schedule: schedule)
                        } label: {
                            HStack {
                                if schedule.schedulePhotos.isEmpty {
                                    Image(systemName: "photo.on.rectangle")
                                        .font(.largeTitle)
                                        .frame(width: 60, height: 60)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(CustomColor.borderColor, lineWidth: 1)
                                        )
                                } else {
                                    Image(uiImage: UIImage(data: schedule.schedulePhotos.last!.schedulePhoto)!)
                                        .resizable()
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .frame(width: 60, height: 60)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(CustomColor.borderColor, lineWidth: 1)
                                        )
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(schedule.scheduleName)
                                        .font(.title2)
                                        .bold()

                                    Text(schedule.scheduleDate.formatted(
                                        date: .numeric, time: .shortened))
                                }

                                Spacer()
                            }
                            .font(.headline)
                        }
                        .listRowBackground(CustomColor.listBackgroundColor)
                        .contextMenu {
                            Button(role: .destructive) {
                                dataController.delete(schedule)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                } header: {
                    Text(week)
                        .foregroundColor(.primary)
                }
            }
        }
        .listStyle(.inset)
    }
    
    var pastList: some View {
        List {
            ForEach(Array(viewModel.pastSchedules()), id: \.key) { month, schedules in
                Section {
                    ForEach(schedules) { schedule in
                        NavigationLink {
                            DetailView(viewModel: viewModel, schedule: schedule)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(schedule.scheduleName)
                                    .bold()

                                Text(schedule.scheduleDate.formatted(date: .numeric, time: .shortened))
                            }
                            .font(.headline)
                            .foregroundColor(.secondary)
                        }
                        .listRowBackground(CustomColor.listBackgroundColor)
                        .contextMenu {
                            Button(role: .destructive) {
                                dataController.delete(schedule)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                } header: {
                    Text(month)
                        .foregroundColor(.primary)
                }
            }
        }
        .listStyle(.inset)
    }
}

struct ScheduleListView_Previews: PreviewProvider {
    static let viewModel = ViewModel(dataController: DataController())

    static var previews: some View {
        ScheduleListView(
            navigationTitle: "Example",
            viewModel: viewModel
        )
        .environmentObject(DataController())
    }
}
