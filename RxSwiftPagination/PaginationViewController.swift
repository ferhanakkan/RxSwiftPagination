//
//  PaginationViewController.swift
//  RxSwiftPagination
//
//  Created by Ferhan Akkan on 11.07.2021.
//

import RxCocoa
import RxSwift
import UIKit

final class PaginationViewController: UIViewController {
    
    private let viewModel = PaginationViewModel()
    private let disposeBag = DisposeBag()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: UITableViewCell.description())
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.refreshControl = refreshControl
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.delegate = self
        return tableView
    }()
    
    private lazy var viewSpinner: UIView = {
        let view = UIView(frame: CGRect(
                            x: 0,
                            y: 0,
                            width: view.frame.size.width,
                            height: 100)
        )
        let spinner = UIActivityIndicatorView()
        spinner.center = view.center
        view.addSubview(spinner)
        spinner.startAnimating()
        return view
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        return refreshControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        layout()
        bind()
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            self.viewModel.fetchMoreDatas.onNext(())
        }
        refreshControl.addTarget(self, action: #selector(refreshControlTriggered), for: .valueChanged)
    }

    private func layout() {

        view.backgroundColor = .white

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
        ])
    }

    private func bind() {
        
        tableViewBind()

        viewModel.isLoadingSpinnerAvaliable.subscribe { [weak self] isAvaliable in
            guard let isAvaliable = isAvaliable.element,
                  let self = self else { return }
            self.tableView.tableFooterView = isAvaliable ? self.viewSpinner : UIView(frame: .zero)
        }
        .disposed(by: disposeBag)

        viewModel.refreshControlCompelted.subscribe { [weak self] _ in
            guard let self = self else { return }
            self.refreshControl.endRefreshing()
        }
        .disposed(by: disposeBag)
    }

    private func tableViewBind() {

        viewModel.items.bind(to: tableView.rx.items) { tableView, _, item in
            tableView.tableFooterView =  UIView(frame: .zero)
            let cell = tableView
                .dequeueReusableCell(withIdentifier: UITableViewCell.description())
            cell?.textLabel?.text = item
            return cell ?? UITableViewCell()
        }
        .disposed(by: disposeBag)

        tableView.rx.itemSelected.bind { [weak self] indexPath in
            guard let self = self else { return }
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
        .disposed(by: disposeBag)

        tableView.rx.didScroll.subscribe { [weak self] _ in
            guard let self = self else { return }
            let offSetY = self.tableView.contentOffset.y
            let contentHeight = self.tableView.contentSize.height

            if offSetY > (contentHeight - self.tableView.frame.size.height - 100) {
                self.viewModel.fetchMoreDatas.onNext(())
            }
        }
        .disposed(by: disposeBag)
    }

    @objc private func refreshControlTriggered() {
        viewModel.refreshControlAction.onNext(())
    }
}

//MARK: - TableViewDelegate

extension PaginationViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200 
    }
}
