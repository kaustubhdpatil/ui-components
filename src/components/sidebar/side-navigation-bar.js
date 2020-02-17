import CssBaseLine from '@bit/mui-org.material-ui.css-baseline';
import Drawer from '@bit/mui-org.material-ui.drawer';
import Icon from '@bit/mui-org.material-ui.icon';
import List from '@bit/mui-org.material-ui.list';
import ListItem from '@bit/mui-org.material-ui.list-item';
import PropTypes from 'prop-types';
import React from 'react';
import { makeStyles } from '@bit/mui-org.material-ui.styles';
import { loadCSS } from 'fg-loadcss';

const drawerWidth = 100;

const useStyles = makeStyles((theme) => ({
    root: {
        display: 'flex',
    },
    drawer: {
        width: drawerWidth,
        flexShrink: 0,
    },
    drawerPaper: {
        width: drawerWidth,
    }
}));

function SideNavigationBar(props) {
    const { navbarItems, fontAwesomeClassName } = props;
    const classes = useStyles();

    React.useEffect(() => {
        loadCSS('https://use.fontawesome.com/releases/v5.1.0/css/all.css');
    }, []);

    return (
        <div>
            <CssBaseLine />
            <Drawer
                anchor="left"
                className={classes.drawer}
                classes={{
                    paper: classes.drawerPaper
                }}
                variant="permanent"
            >
                <List>
                    {
                        navbarItems.map((value, index) => (
                            <ListItem
                                button
                                key={value.label}
                                title={value.tooltip}
                            >
                                <div className={classes.navbarItemDiv}>
                                    {
                                        fontAwesomeClassName
                                        ? <Icon className={`fa ${fontAwesomeClassName}`}/>
                                        : <Icon>{value.icon}</Icon>
                                    }
                                    {value.label}
                                </div>
                            </ListItem>
                        ))
                    }
                </List>
            </Drawer>
        </div>
    );
}

const navbarItem = {
    label: PropTypes.string,
    icon: PropTypes.string,
    tooltip: PropTypes.string,
    fontAwesomeClassName: PropTypes.string
};

SideNavigationBar.propTypes = {
    navbarItems: PropTypes.arrayOf(PropTypes.shape(navbarItem))
};

export default SideNavigationBar;