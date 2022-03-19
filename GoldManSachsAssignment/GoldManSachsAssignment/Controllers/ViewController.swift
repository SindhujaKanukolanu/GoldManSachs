//
//  ViewController.swift
//  GoldManSachsAssignment
//
//  Created by Sri Sai Sindhuja, Kanukolanu on 19/03/22.
//

import UIKit
import Combine

class ViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var searchController = UISearchController(searchResultsController: nil)
    
    let rowIdentifier = "listIdentifier"
    
    let loadingView = UIView()
    
    /// Spinner shown during load the TableView
    let spinner = UIActivityIndicatorView()
    
    /// Text shown during load the TableView
    let loadingLabel = UILabel()

    
    private lazy var datasource = makeDatasource()
    
    var viewModel = DataSourceViewModel()
    
    var cancellables = [AnyCancellable]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableviewCells()
        setLoadingScreen()
        configureSearchController()
        setupBindings()
        
        // delay and update tableview
        self.update(with: self.viewModel.cards)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //destory all subscriptions
        cancellables.forEach { (subscriber) in
            subscriber.cancel()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.update(with: self.viewModel.cards)
    }
    private func setupBindings() {
        let publisher = viewModel.fetchCards()
        publisher
            .receive(on: DispatchQueue.main)
            .sink { (completion) in
                if case .failure(let error) = completion {
                    print("fetch error -- \(error)")
                }
            } receiveValue: { [weak self] cards in
                self?.update(with: cards)
            }.store(in: &cancellables)
    }
    
    private func setupTableviewCells() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: rowIdentifier)
        tableView.dataSource = datasource
        tableView.delegate = self
        
        tableView.rowHeight = 100.0
        tableView.estimatedRowHeight = UITableView.automaticDimension
        
        tableView.contentInset = UIEdgeInsets(top: 20.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionModel = datasource.snapshot().sectionIdentifiers[section]
        
        let label = UILabel()
        label.text = sectionModel.title
        return label
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // on row selection
        let rowModel = datasource.snapshot().sectionIdentifiers[indexPath.section].rows[indexPath.row]
        print(rowModel)
        
    }
    
    // Set the activity indicator into the main view
        private func setLoadingScreen() {

            // Sets the view which contains the loading text and the spinner
            let width: CGFloat = 120
            let height: CGFloat = 30
            let x = (tableView.frame.width / 2) - (width / 2)
            let y = (tableView.frame.height / 2) - (height / 2)
            loadingView.frame = CGRect(x: x, y: y, width: width, height: height)

            // Sets loading text
            loadingLabel.textColor = .gray
            loadingLabel.textAlignment = .center
            loadingLabel.text = "Loading..."
            loadingLabel.frame = CGRect(x: 0, y: 0, width: 140, height: 30)

            // Sets spinner
            spinner.style = UIActivityIndicatorView.Style.medium
            spinner.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            spinner.startAnimating()

            // Adds text and spinner to the view
            loadingView.addSubview(spinner)
            loadingView.addSubview(loadingLabel)

            tableView.addSubview(loadingView)

        }
    
    // Remove the activity indicator from the main view
        private func removeLoadingScreen() {
            // Hides and stops the text and the spinner
            spinner.stopAnimating()
            spinner.isHidden = true
            loadingLabel.isHidden = true
        }
}

// all diffable dataosurce code
extension ViewController {
    
    // create diffable tableview datasource
    private func makeDatasource() -> UITableViewDiffableDataSource<SectionModel, DataModel> {
        let reuseIdentifier = rowIdentifier
        
        return UITableViewDiffableDataSource<SectionModel, DataModel>(tableView: tableView) { tableView, indexPath, rowModel -> UITableViewCell? in
            var cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
            if cell.detailTextLabel == nil {
                cell = UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier)
            }
            cell.textLabel?.text = rowModel.explanation
            cell.textLabel?.sizeToFit()
            cell.textLabel?.numberOfLines = 1
            //cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.imageView?.image = self.viewModel.dataImage
            cell.imageView?.backgroundColor = UIColor.darkGray
            cell.detailTextLabel?.text = rowModel.date
            let label = UILabel(frame: CGRect(x: cell.frame.origin.x + 20, y: 30, width: cell.frame.width, height: cell.frame.width))
            label.text = rowModel.explanation
            label.textColor = UIColor.red

            return cell
        }
        
    }
    
    func update(with cards: [SectionModel], animate: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<SectionModel, DataModel>()
        
        cards.forEach { (section) in
            removeLoadingScreen()
            snapshot.appendSections([section])
            snapshot.appendItems(section.rows, toSection: section)
        }
        
        datasource.apply(snapshot, animatingDifferences: animate, completion: nil)
    }
    
    func remove(_ card: DataModel, animate: Bool = true) {
        var snapshot = datasource.snapshot()
        snapshot.deleteItems([card])
        datasource.apply(snapshot, animatingDifferences: animate, completion: nil)
    }
    
}

extension ViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        var filteredData = [SectionModel]()
        filteredData = filteredValues(for: searchController.searchBar.text)
        self.update(with: filteredData)
    }
    
    func filteredValues(for queryOrNil: String?) -> [SectionModel] {
        let sections = viewModel.cards
        var filteredCards = [SectionModel]()
        guard
            let query = queryOrNil,
            !query.isEmpty
        else {
            return sections
        }
        for rows in sections {
            print(rows)
        }
        for eachSection in sections {
            for name in eachSection.rows {
                let character = query[...]
                for char in query {
                    if char == character[character.startIndex] {
                        if !character.isEmpty {
                            if name.date.contains(character.base.uppercased()) || name.date.contains(character.base) {
                                filteredCards.append(contentsOf: [SectionModel(title: "", rows: [name])])
                            }
                        }
                    }
                }
            }
        }
        return filteredCards
    }
    
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Details"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        tableView.addSubview(searchController.searchBar)
    }
    
}


