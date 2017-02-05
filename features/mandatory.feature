Feature: mandatory input fields

  Scenario: valid values
    Given I use the current directory as working directory
    Given a file named "tmp.yml" with:
"""
ci: true
servers:
  - name: db1
    boot:
        script: deploy/boot_db.sh
        logs:
        - /tmp/firstboot.log
        - /tmp/SimpleHTTPServer.log
        ports:
        - 9042
  - name: app1
    start:
        script: deploy/start_ss7cli.sh
        logs:
        - /tmp/firstboot.log
        - /tmp/SimpleHTTPServer.log
        ports:
        - 3435
        dependencies:
            CASSANDRA_IP: db1
"""
    When file tmp.yml is given then the program passes